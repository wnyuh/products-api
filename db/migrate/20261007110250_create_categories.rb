class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      # null: false có nghĩa là bắt buộc phải có không được để trống.
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end

    # unique: true có nghĩa là duy nhất không có mục nào trùng nhau.
    add_index :categories, :slug, unique: true
  end
end
