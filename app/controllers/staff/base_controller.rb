module Staff
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_staff!

    layout "staff"

    private

    def require_staff!
      return if current_user&.admin? || current_user&.staff?

      redirect_to root_path, alert: "権限がありません"
    end
  end
end
