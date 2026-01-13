class AddSortOrderToCategories < ActiveRecord::Migration[7.2]
  def change
    add_column :categories, :sort_order, :integer, null: false, default: 0
    add_index :categories, :sort_order
  end
end
