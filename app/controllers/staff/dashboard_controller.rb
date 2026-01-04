module Staff
  class DashboardController < BaseController
    def index
      @open_orders = Order.open.includes(:table).order(updated_at: :desc).limit(50)
      @billing_orders = Order.billing.includes(:table).order(updated_at: :desc).limit(50)
      @calls = Call.open_only.includes(:table).order(created_at: :desc).limit(50)
    end
  end
end
