module Staff
  class OrdersController < BaseController
    def index
      scope = Order.includes(:table).order(updated_at: :desc)
      scope = scope.where(status: params[:status]) if params[:status].present?
      @orders = scope.limit(200)
    end

    def show
      @order = Order.includes(order_items: :item, table: {}).find(params[:id])
    end

    def start_billing
      order = Order.find(params[:id])
      order.start_billing!
      redirect_to staff_order_path(order), notice: "会計を開始しました"
    rescue StandardError => e
      redirect_to staff_order_path(order), alert: e.message
    end
  end
end
