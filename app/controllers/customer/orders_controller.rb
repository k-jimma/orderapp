module Customer
  class OrdersController < BaseController
    include TableAccessGuard

    def show
      # 注文内容表示
      @order = find_or_create_open_order!
      @order_items = @order.order_items.includes(:item).order(:id)
    end

    def create
      # 注文確定処理
      @order = find_or_create_open_order!
      items_params = params.dig(:order, :order_items) || []

      if items_params.blank?
        return redirect_to table_items_path(token: current_table.token), alert: "注文が空です"
      end

      # カートから複数商品を一括追加
      items_params.each do |item_row|
        Orders::AddItem.new(
          order: @order,
          item_id: item_row[:item_id] || item_row["item_id"],
          quantity: item_row[:quantity] || item_row["quantity"],
          note: item_row[:note] || item_row["note"]
        ).call!
      end

      redirect_to complete_table_order_path(token: current_table.token), notice: "注文を受け付けました"
    rescue Order::OrderClosedError => e
      redirect_to table_order_path(token: current_table.token), alert: e.message
    rescue StandardError => e
      redirect_to table_items_path(token: current_table.token), alert: e.message
    end

    def complete
      # 注文完了画面
      @order = current_table.orders.open.first
      redirect_to table_items_path(token: current_table.token), alert: "受付中の注文がありません" unless @order
    end
  end
end
