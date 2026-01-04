class CreateTables < ActiveRecord::Migration[7.2]
  def change
    create_table :tables do |t|
      t.integer :number, null: false
      t.string :token, null: false
      t.integer :access_mode, null: false, default: 0
      t.boolean :active, null: false, default: false
      t.datetime :token_expires_at
      t.string :pin_digest
      t.datetime :pin_rotated_at
      t.datetime :last_used_at

      t.timestamps
    end

    add_index :tables, :number, unique: true
    add_index :tables, :token, unique: true
    add_index :tables, :active
  end
end
