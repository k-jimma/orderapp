module Table
  class OrderItemsController < BaseController
    include TableAccessGuard

    def index
      @order = find_or_create_open_order!
      @order_items = @order.order_items.includes(:item).order(:id)
    end

    def create
      @order = find_or_create_open_order!
      Orders::AddItem.new(
        order: @order,
        item_id: order_item_params[:item_id],
        quantity: order_item_params[:quantity],
        note: order_item_params[:note]
      ).call!

      redirect_to table_order_path(token: current_table.token), notice: "追加しました"
    rescue Order::OrderClosedError => e
      redirect_to table_order_path(token: current_table.token), alert: e.message
    rescue StandardError => e
      redirect_to table_items_path(token: current_table.token), alert: e.message
    end

    private

    def order_item_params
      params.require(:order_item).permit(:item_id, :quantity, :note)
    end
  end
end
