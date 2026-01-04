class CreateOrderItems < ActiveRecord::Migration[7.2]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.integer :unit_price, null: false
      t.integer :status, null: false, default: 0
      t.text :note

      t.timestamps
    end

    add_index :order_items, :status
  end
end
