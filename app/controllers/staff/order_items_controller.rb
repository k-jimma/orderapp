module Staff
  class OrderItemsController < BaseController
    before_action :set_order
    before_action :set_order_item

    # ステータス遷移アクション
    def to_cooking = transition!(:cooking)
    def to_ready = transition!(:ready)
    def to_served = transition!(:served)
    def cancel = transition!(:canceled)

    private

    def set_order
      # 親リソースの注文を取得
      @order = Order.find(params[:order_id])
    end

    def set_order_item
      # 操作対象の注文商品を取得
      @order_item = @order.order_items.find(params[:id])
    end

    def transition!(to_status)
      # ステータス遷移はモデル側でバリデーション
      @order_item.transition_to!(to_status)
      redirect_to staff_order_path(@order), notice: "更新しました"
    rescue OrderItem::InvalidTransitionError => e
      redirect_to staff_order_path(@order), alert: e.message
    rescue StandardError => e
      redirect_to staff_order_path(@order), alert: e.message
    end
  end
end
