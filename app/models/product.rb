class Product < ApplicationRecord
  has_one_attached :image
  belongs_to :category
  # Sử dụng delegation: tạo method slug/name trực tiếp thuộc Product
  # nhờ delegation, chúng ta có thể gọi slug/name thay vì category.slug/category.name
  # prefix: true tạo category_slug, category_name (không đè Product#name)
  delegate :slug, :name, to: :category, prefix: true

  normalizes :name, with: ->(value) { value.strip }

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }
  validates :price, numericality: { greater_than_or_equal_to: 0, less_than: 10**10 }

  # URL tuyệt đối tới ảnh (proxy qua Rails, không redirect) hoặc nil nếu chưa có ảnh.
  def image_url
    Rails.application.routes.url_helpers.rails_storage_proxy_url(image) if image.attached?
  end

  # JSON vẫn giữ key image_url như contract cũ để frontend không phải đổi.
  def serializable_hash(options = nil)
    super.merge(
      "image_url" => image_url,
      "category" => category_slug,
      "category_name" => category_name
    )
  end
end
