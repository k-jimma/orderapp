class AddParentToCategories < ActiveRecord::Migration[7.2]
  def change
    add_reference :categories, :parent, foreign_key: { to_table: :categories }
    remove_index :categories, :name
    add_index :categories, [:parent_id, :name], unique: true
  end
end
