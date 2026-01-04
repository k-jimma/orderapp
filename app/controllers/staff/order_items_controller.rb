module Staff
  class OrderItemsController < BaseController
    before_action :set_order
    before_action :set_order_item

    def to_cooking = transition!(:cooking)
    def to_ready = transition!(:ready)
    def to_served = transition!(:served)
    def cancel = transition!(:canceled)

    private

    def set_order
      @order = Order.find(params[:order_id])
    end

    def set_order_item
      @order_item = @order.order_items.find(params[:id])
    end

    def transition!(to_status)
      @order_item.transition_to!(to_status)
      redirect_to staff_order_path(@order), notice: "更新しました"
    rescue OrderItem::InvalidTransitionError => e
      redirect_to staff_order_path(@order), alert: e.message
    rescue StandardError => e
      redirect_to staff_order_path(@order), alert: e.message
    end
  end
end
