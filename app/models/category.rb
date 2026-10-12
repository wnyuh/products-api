class Category < ApplicationRecord
  has_many :products, dependent: :restrict_with_error

  normalizes :name, with: ->(value) { value.strip }
  normalizes :slug, with: ->(value) { value.strip.downcase }

  validates :name, presence: true, length: { maximum: 50 },
            uniqueness: { case_sensitive: false }
  validates :slug, presence: true, length: { maximum: 30 },
            uniqueness: true,
            format: { with: /\A[a-z][a-z0-9_]*\z/,
                      message: "must be lowercase letters, digits or underscores, starting with a letter" }
end
