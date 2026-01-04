class Item < ApplicationRecord
  belongs_to :category, inverse_of: :items
  has_many :order_items, dependent: :restrict_with_error, inverse_of: :item

  validates :name, presence: true
  validates :price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :available, -> { where(is_available: true) }
end
