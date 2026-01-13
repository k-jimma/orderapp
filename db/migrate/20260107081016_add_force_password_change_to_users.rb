class AddForcePasswordChangeToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :force_password_change, :boolean, null: false, default: true
    add_column :users, :password_changed_at, :datetime

    add_index :users, :force_password_change
    add_index :users, :password_changed_at
  end
end
