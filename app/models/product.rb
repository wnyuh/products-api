class Product < ApplicationRecord
  # Chuẩn hóa trước khi validate để "Case " và "case" là cùng một category
  normalizes :name, with: ->(value) { value.strip }
  normalizes :category, with: ->(value) { value.strip.downcase }

  validates :name, presence: true, length: { maximum: 100 }
  validates :category, presence: true, length: { maximum: 30 },
            format: { with: /\A[a-z][a-z0-9_]*\z/,
                      message: "must be lowercase letters, digits or underscores, starting with a letter" }
  validates :description, length: { maximum: 500 }
  validates :price, numericality: { greater_than_or_equal_to: 0, less_than: 10**10 }
end
