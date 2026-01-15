module TableTokenAuth
  extend ActiveSupport::Concern

  included do
    # テーブルのトークン認証を共通化
    before_action :set_current_table
    helper_method :current_table
  end

  private

  def set_current_table
    # URL パラメータからトークンを取得してテーブルを特定
    table_token = params[:token].to_s
    @current_table = Table.find_by(token: table_token)
    return render(status: :not_found, plain: "テーブルが見つかりません") if @current_table.nil?

    if AppSetting.instance.token_expiry_enabled? &&
        @current_table.token_expires_at.present? &&
        @current_table.token_expires_at < Time.current
      return render(status: :forbidden, plain: "トークンの有効期限が切れています")
    end

    return render(status: :forbidden, plain: "テーブルが無効です") unless @current_table.active?

    if @current_table.last_used_at.nil? || @current_table.last_used_at < 10.minutes.ago
      @current_table.update_column(:last_used_at, Time.current)
    end
  end

  def current_table
    # 現在のテーブルを返す
    @current_table
  end
end
