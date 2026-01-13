module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!

    layout "admin"

    private

    def require_admin!
      return if current_user&.admin? || current_user&.chief?

      redirect_to root_path, alert: "管理者権限が必要です"
    end

    def require_chief!
      return if current_user&.chief?

      redirect_to admin_root_path, alert: "最高責任者権限が必要です"
    end
  end
end
