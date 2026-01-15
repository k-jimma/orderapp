class Payment < ApplicationRecord
  has_many :payment_orders, dependent: :destroy, inverse_of: :payment
  has_many :orders, through: :payment_orders

  # pending: 未確定 / paid: 支払済み / void: 取消
  enum status: { pending: 0, paid: 1, void: 9 }
  enum payment_method: { cash: 0 }

  validates :amount, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :discount_amount, :rounding_adjustment, numericality: { only_integer: true }, presence: true

  def expected_amount
    # 注文小計合計 - 値引き + 端数調整
    orders.sum(&:subtotal) - discount_amount + rounding_adjustment
  end

  def amounts_match?
    # 支払金額と期待金額が一致するかどうか
    amount.to_i == expected_amount.to_i
  end
end
