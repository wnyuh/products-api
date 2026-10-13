class CreateProductExports < ActiveRecord::Migration[8.1]
  def change
    create_table :product_exports do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "pending" # mặc định ở tầng database
      t.json :filters                                   # bộ lọc để job đọc lại
      t.text :error_message
      t.datetime :completed_at
      t.timestamps
    end
  end
end
