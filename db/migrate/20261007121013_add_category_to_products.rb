class AddCategoryToProducts < ActiveRecord::Migration[8.1]
  CATEGORY_NAMES = {
    "iphone" => "iPhone", "mac" => "Mac", "ipad" => "iPad",
    "apple_watch" => "Apple Watch", "airpods" => "AirPods",
    "tv_home" => "TV & Nhà", "accessories" => "Phụ kiện"
  }.freeze

  class MigrationCategory < ApplicationRecord
    self.table_name = "categories"
  end

  class MigrationProduct < ApplicationRecord
    self.table_name = "products"
  end

  def up
    add_reference :products, :category, foreign_key: true, null: true

    MigrationProduct.reset_column_information

    # distinct.pluck là lấy danh sách các chữ khác nhau.
    MigrationProduct.distinct.pluck(:category).each do |slug|
      name = CATEGORY_NAMES.fetch(slug) { slug.tr("_", " ").titleize }
      category = MigrationCategory.find_or_create_by!(slug: slug) { |c| c.name = name }
      MigrationProduct.where(category: slug).update_all(category_id: category.id)
    end

    # chặn các sản phẩm không có danh mục.
    change_column_null :products, :category_id, false
  end

  # dùng để quay về trạng thái ban đầu an toàn vì cột chữ category trước đó vẫn còn
  def down
    remove_reference :products, :category, foreign_key: true
  end
end
