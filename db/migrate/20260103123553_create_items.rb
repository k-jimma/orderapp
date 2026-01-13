class CreateItems < ActiveRecord::Migration[7.2]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.integer :price, null: false, default: 0
      t.references :category, null: false, foreign_key: true
      t.boolean :is_available, null: false, default: true

      t.timestamps
    end

    add_index :items, :is_available
  end
end
