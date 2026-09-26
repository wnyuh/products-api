class CreateIphones < ActiveRecord::Migration[8.1]
  def change
    create_table :iphones do |t|
      t.string :name, null: false
      t.integer :storage, null: false
      t.decimal :price, precision: 12, scale: 2, null: false
      t.string :color

      t.timestamps
    end
  end
end
