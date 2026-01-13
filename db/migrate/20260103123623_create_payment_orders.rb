class CreatePaymentOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :payment_orders do |t|
      t.references :payment, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true

      t.timestamps
    end

    add_index :payment_orders, [ :payment_id, :order_id ], unique: true
  end
end
