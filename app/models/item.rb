class Item < ApplicationRecord
  belongs_to :category, inverse_of: :items
  has_many :order_items, dependent: :restrict_with_error, inverse_of: :item

  validates :name, presence: true
  validates :price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :category_cannot_be_root

  # 販売中のみを返すスコープ
  scope :available, -> { where(is_available: true) }

  private

  def category_cannot_be_root
    # ルートカテゴリを選択できない
    return unless category
    if category.root?
      errors.add(:category, "は大カテゴリを選択できません")
    end
  end
end
