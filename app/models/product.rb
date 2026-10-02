class Product < ApplicationRecord
  has_one_attached :image

  # Chuẩn hóa trước khi validate để "Case " và "case" là cùng một category
  normalizes :name, with: ->(value) { value.strip }
  normalizes :category, with: ->(value) { value.strip.downcase }

  validates :name, presence: true, length: { maximum: 100 }
  validates :category, presence: true, length: { maximum: 30 },
            format: { with: /\A[a-z][a-z0-9_]*\z/,
                      message: "must be lowercase letters, digits or underscores, starting with a letter" }
  validates :description, length: { maximum: 500 }
  validates :price, numericality: { greater_than_or_equal_to: 0, less_than: 10**10 }

  # URL tuyệt đối tới ảnh (proxy qua Rails, không redirect) hoặc nil nếu chưa có ảnh.
  def image_url
    Rails.application.routes.url_helpers.rails_storage_proxy_url(image) if image.attached?
  end

  # JSON vẫn giữ key image_url như contract cũ để frontend không phải đổi.
  def serializable_hash(options = nil)
    super.merge("image_url" => image_url)
  end
end
