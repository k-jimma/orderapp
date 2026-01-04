class CreateCalls < ActiveRecord::Migration[7.2]
  def change
    create_table :calls do |t|
      t.references :table, null: false, foreign_key: true
      t.integer :kind, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.string :message

      t.timestamps
    end

    add_index :calls, :status
    add_index :calls, :kind
  end
end
