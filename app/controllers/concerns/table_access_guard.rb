module TableAccessGuard
  extend ActiveSupport::Concern

  included do
    before_action :require_table_access!
  end

  private

  def require_table_access!
    return if AppSetting.instance.open_access_for?(current_table)
    return if table_access_granted?

    redirect_to table_access_new_path(token: current_table.token), alert: "PINの入力が必要です"
  end

  def table_access_granted?
    session.dig(:table_access, current_table.id.to_s) == true
  end

  def grant_table_access!
    session[:table_access] ||= {}
    session[:table_access][current_table.id.to_s] = true
  end

  def revoke_table_access!
    session[:table_access] ||= {}
    session[:table_access].delete(current_table.id.to_s)
  end
end
