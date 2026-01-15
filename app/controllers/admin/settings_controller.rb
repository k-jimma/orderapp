module Admin
  class SettingsController < BaseController
    def edit
      # 現在のアプリ設定を取得
      @settings = AppSetting.instance
    end

    def update
      # アプリ設定の更新
      @settings = AppSetting.instance
      @settings.update!(settings_params)
      redirect_to edit_admin_settings_path, notice: "設定を更新しました"
    rescue StandardError => e
      redirect_to edit_admin_settings_path, alert: e.message
    end

    private

    def settings_params
      # chief のみゲストログイン設定を操作可能
      permitted = [
        :token_expiry_enabled,
        :default_access_mode,
        :global_access_mode
      ]
      permitted << :guest_logins_enabled if current_user&.chief?
      params.require(:app_setting).permit(*permitted)
    end
  end
end
