module Customer
  class OrdersController < BaseController
    include TableAccessGuard

    def show
      @order = find_or_create_open_order!
      @order_items = @order.order_items.includes(:item).order(:id)
    end

    # カート一括送信
    def create
      @order = find_or_create_open_order!
      items_params = params.dig(:order, :order_items) || []

      if items_params.blank?
        return redirect_to table_items_path(token: current_table.token), alert: "注文が空です"
      end

      items_params.each do |row|
        Orders::AddItem.new(
          order: @order,
          item_id: row[:item_id] || row["item_id"],
          quantity: row[:quantity] || row["quantity"],
          note: row[:note] || row["note"]
        ).call!
      end

      redirect_to complete_table_order_path(token: current_table.token), notice: "注文を受け付けました"
    rescue Order::OrderClosedError => e
      redirect_to table_order_path(token: current_table.token), alert: e.message
    rescue StandardError => e
      redirect_to table_items_path(token: current_table.token), alert: e.message
    end

    def complete
      @order = current_table.orders.open.first
      redirect_to table_items_path(token: current_table.token), alert: "受付中の注文がありません" unless @order
    end
  end
end
