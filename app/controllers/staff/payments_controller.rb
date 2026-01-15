module Staff
  class PaymentsController < BaseController
    def new
      # 会計対象の注文を取得
      @orders = Order.billing.includes(:table, order_items: :item).where(id: params[:order_ids])
      # 対象注文がない場合は一覧へ戻す
      redirect_to(staff_orders_path(status: :billing), alert: "対象がありません") if @orders.blank?
    end

    def create
      # 会計処理を実行
      payment = Payments::CloseTablePayment.new(
        order_ids: payment_params[:order_ids],
        discount_amount: payment_params[:discount_amount],
        rounding_adjustment: payment_params[:rounding_adjustment],
        received_cash: payment_params[:received_cash],
        note: payment_params[:note]
      ).call!

      redirect_to staff_payment_path(payment), notice: "会計完了"
    rescue StandardError => e
      redirect_to staff_orders_path(status: :billing), alert: e.message
    end

    def show
      # 会計情報を取得
      @payment = Payment.includes(orders: :table).find(params[:id])
    end

    private

    def payment_params
      # 強く許可するパラメータを指定
      params.require(:payment).permit(:discount_amount, :rounding_adjustment, :received_cash, :note, order_ids: [])
    end
  end
end
