module TableTokenAuth
  extend ActiveSupport::Concern

  included do
    before_action :set_current_table
    helper_method :current_table
  end

  private

  def set_current_table
    token = params[:token].to_s
    @current_table = Table.find_by(token: token)
    return render(status: :not_found, plain: "Table not found") if @current_table.nil?

    if @current_table.token_expires_at.present? && @current_table.token_expires_at < Time.current
      return render(status: :forbidden, plain: "Token expired")
    end

    return render(status: :forbidden, plain: "Table is inactive") unless @current_table.active?

    if @current_table.last_used_at.nil? || @current_table.last_used_at < 10.minutes.ago
      @current_table.update_column(:last_used_at, Time.current)
    end
  end

  def current_table
    @current_table
  end
end
