class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.references :table, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :people_count
      t.integer :cached_total, default: 0
      t.datetime :closed_at

      t.timestamps
    end

    add_index :orders, :status
  end
end
