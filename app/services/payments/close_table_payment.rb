module Payments
  class CloseTablePayment
    def initialize(order_ids:, discount_amount:, rounding_adjustment:, received_cash:, note:)
      @order_ids = Array(order_ids).map(&:to_i)
      @discount_amount = discount_amount.to_i
      @rounding_adjustment = rounding_adjustment.to_i
      @received_cash = received_cash.presence&.to_i
      @note = note
    end

    def call!
      orders = Order.includes(:table, order_items: :item).where(id: @order_ids)
      raise ArgumentError, "対象注文がありません" if orders.blank?
      raise ArgumentError, "会計対象はbillingの注文のみです" unless orders.all?(&:billing?)
      raise ArgumentError, "同一テーブルのみ会計可能です" unless orders.map(&:table_id).uniq.size == 1

      ApplicationRecord.transaction do
        subtotal_sum = orders.sum(&:subtotal)
        amount = subtotal_sum - @discount_amount + @rounding_adjustment
        raise ArgumentError, "金額が不正です" if amount < 0
        if @received_cash && @received_cash < amount
          raise ArgumentError, "受領金額が不足しています"
        end

        payment = Payment.create!(
          amount: amount,
          discount_amount: @discount_amount,
          rounding_adjustment: @rounding_adjustment,
          received_cash: @received_cash,
          change: @received_cash ? (@received_cash - amount) : nil,
          paid_at: Time.current,
          payment_method: :cash,
          status: :paid,
          note: @note
        )

        orders.each do |o|
          PaymentOrder.create!(payment: payment, order: o)
          o.update!(status: :closed, closed_at: Time.current)
        end

        table = orders.first.table
        table.update!(active: false)
        table.rotate_token!

        payment
      end
    end
  end
end
