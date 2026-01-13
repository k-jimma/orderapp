class AddGuestLoginsEnabledToAppSettings < ActiveRecord::Migration[7.2]
  def change
    add_column :app_settings, :guest_logins_enabled, :boolean, null: false, default: true
  end
end
