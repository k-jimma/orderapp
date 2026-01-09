class AddCommonPinToAppSettings < ActiveRecord::Migration[7.2]
  def change
    add_column :app_settings, :common_pin, :string
  end
end
