module Staff
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_staff!
    before_action :load_tables_for_switcher
    before_action :force_password_change_if_needed

    layout "staff"

    private

    def force_password_change_if_needed
      return unless current_user&.staff?
      return if current_user.guest?
      return unless current_user.force_password_change?
      return if controller_name == "passwords"

      redirect_to edit_staff_password_path, alert: "初回ログインのためパスワード変更が必要です"
    end

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
