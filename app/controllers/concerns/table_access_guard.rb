module TableAccessGuard
  extend ActiveSupport::Concern

  included do
    before_action :require_table_access!
  end

  private

  def require_table_access!
    return if AppSetting.instance.open_access_for?(current_table)
    return if table_access_granted?

    redirect_to new_table_access_path(token: current_table.token), alert: "PINの入力が必要です"
  end

  def table_access_granted?
    stored = session.dig(:table_access, current_table.id.to_s)
    return false if stored.blank?

    granted_at =
      case stored
      when Hash
        stored["pin_rotated_at"] || stored[:pin_rotated_at]
      else
        nil
      end

    table_rotated_at = current_table.pin_rotated_at&.to_i
    granted_at_i = granted_at.to_i

    granted_at_i == (table_rotated_at || 0)
  end

  def grant_table_access!
    session[:table_access] ||= {}
    session[:table_access][current_table.id.to_s] = {
      pin_rotated_at: (current_table.pin_rotated_at&.to_i || 0)
    }
  end

  def revoke_table_access!
    session[:table_access] ||= {}
    session[:table_access].delete(current_table.id.to_s)
  end
end
