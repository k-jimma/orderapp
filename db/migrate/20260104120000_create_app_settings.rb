class CreateAppSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :app_settings do |t|
      t.boolean :token_expiry_enabled, null: false, default: false
      t.integer :default_access_mode, null: false, default: 0
      t.integer :global_access_mode

      t.timestamps
    end
  end
end
