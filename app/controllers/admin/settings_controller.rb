module Admin
  class SettingsController < BaseController
    def edit
      @settings = AppSetting.instance
    end

    def update
      @settings = AppSetting.instance
      @settings.update!(settings_params)
      redirect_to edit_admin_settings_path, notice: "設定を更新しました"
    rescue StandardError => e
      redirect_to edit_admin_settings_path, alert: e.message
    end

    private

    def settings_params
      params.require(:app_setting).permit(:token_expiry_enabled, :default_access_mode, :global_access_mode)
    end
  end
end
