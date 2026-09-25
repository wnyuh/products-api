class Iphone < ApplicationRecord
  validates :name, presence: true, length: { maximum: 100 }
  validates :color, length: { maximum: 50 }
  validates :storage, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 4096 }
  # price < 10**10 keeps values within 10 integer digits
  validates :price, numericality: { greater_than_or_equal_to: 0, less_than: 10**10 }
end
