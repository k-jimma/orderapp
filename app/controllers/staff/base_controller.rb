module Staff
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_staff!
    before_action :load_tables_for_switcher

    layout "staff"

    private

    def require_staff!
      return if current_user&.admin? || current_user&.staff?

      redirect_to root_path, alert: "権限がありません"
    end

    def load_tables_for_switcher
      @staff_tables = Table.order(:number).select(:id, :number, :token)
    end

    helper_method :staff_tables
    def staff_tables
      @staff_tables
    end
  end
end
