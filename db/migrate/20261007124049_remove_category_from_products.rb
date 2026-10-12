class RemoveCategoryFromProducts < ActiveRecord::Migration[8.1]
  def up
    remove_index :products, :category
    remove_column :products, :category
  end

  def down
    add_column :products, :category, :string

    execute <<~SQL
      UPDATE products
      SET category = (SELECT slug FROM categories WHERE categories.id = products.category_id)
    SQL

    change_column_null :products, :category, false
    add_index :products, :category
  end
end
