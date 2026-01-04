module Staff
  class PaymentsController < BaseController
    def new
      @orders = Order.billing.includes(:table, order_items: :item).where(id: params[:order_ids])
      return redirect_to(staff_orders_path(status: :billing), alert: "対象がありません") if @orders.blank?
    end

    def create
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
      @payment = Payment.includes(orders: :table).find(params[:id])
    end

    private

    def payment_params
      params.require(:payment).permit(:discount_amount, :rounding_adjustment, :received_cash, :note, order_ids: [])
    end
  end
end
