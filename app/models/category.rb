class Category < ApplicationRecord
  has_many :items, dependent: :destroy, inverse_of: :category

  validates :name, presence: true, uniqueness: true
end
