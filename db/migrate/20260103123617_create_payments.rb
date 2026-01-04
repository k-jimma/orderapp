class CreatePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :payments do |t|
      t.integer :amount, null: false
      t.integer :discount_amount, null: false, default: 0
      t.integer :rounding_adjustment, null: false, default: 0
      t.integer :received_cash
      t.integer :change
      t.datetime :paid_at
      t.integer :payment_method, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.text :note

      t.timestamps
    end

    add_index :payments, :paid_at
    add_index :payments, :status
  end
end
