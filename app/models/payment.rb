class Payment < ApplicationRecord
  has_many :payment_orders, dependent: :destroy, inverse_of: :payment
  has_many :orders, through: :payment_orders

  enum status: { pending: 0, paid: 1, void: 9 }
  enum payment_method: { cash: 0 }

  validates :amount, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :discount_amount, :rounding_adjustment, numericality: { only_integer: true }, presence: true

  def expected_amount
    orders.sum(&:subtotal) - discount_amount + rounding_adjustment
  end

  def amounts_match?
    amount.to_i == expected_amount.to_i
  end
end
