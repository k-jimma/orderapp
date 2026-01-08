class AddInitialPasswordToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :initial_password_ciphertext, :text
    add_column :users, :initial_password_set_at, :datetime
    add_column :users, :initial_password_changed_at, :datetime

    add_index :users, :initial_password_set_at
    add_index :users, :initial_password_changed_at
  end
end
