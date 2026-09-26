class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.decimal :price, precision: 12, scale: 2, null: false
      t.string :category, null: false
      t.text :description

      t.timestamps
    end

    add_index :products, :category
  end
end
