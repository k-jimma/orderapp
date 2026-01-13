class AddPortfolioToTables < ActiveRecord::Migration[7.1]
  def change
    add_column :tables, :portfolio, :boolean, null: false, default: false
    add_index :tables, :portfolio
  end
end
