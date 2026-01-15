module Staff
  class OrdersController < BaseController
    def index
      # 一覧は重くなりやすいため最新更新順 + 件数制限を入れる
      orders_scope = Order.includes(:table).order(updated_at: :desc)

      status_filter = params[:status].presence
      orders_scope = orders_scope.where(status: status_filter) if status_filter

      @orders = orders_scope.limit(200)
    end

    def show
      # 詳細は関連データも含めて取得
      @order = Order.includes(:table, order_items: :item).find(params[:id])
    end

    def start_billing
      # 会計開始時にテーブルを無効化して新規注文を止める
      order = Order.find(params[:id])
      ActiveRecord::Base.transaction do
        order.start_billing!
        order.table.update!(active: false)
      end

      redirect_to staff_order_path(order), notice: "会計を開始しました"
    rescue ActiveRecord::RecordNotFound
      redirect_to staff_orders_path, alert: "注文が見つかりません"
    rescue StandardError => e
      redirect_to(order ? staff_order_path(order) : staff_orders_path, alert: e.message)
    end
  end
end
