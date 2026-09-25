class CreateIphones < ActiveRecord::Migration[8.1]
  def change
    create_table :iphones do |t|
      t.string :name
      t.integer :storage
      t.decimal :price
      t.string :color

      t.timestamps
    end
  end
end
