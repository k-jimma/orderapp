module Staff
  class DashboardController < BaseController
    def index
      # 画面で使う最新の状況を絞って取得
      @open_orders = Order.open.includes(:table).order(updated_at: :desc).limit(50)
      @billing_orders = Order.billing.includes(:table).order(updated_at: :desc).limit(50)
      @calls = Call.open_only.includes(:table).order(created_at: :desc).limit(50)
    end
  end
end
