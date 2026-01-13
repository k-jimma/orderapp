class PaymentOrder < ApplicationRecord
  belongs_to :payment, inverse_of: :payment_orders
  belongs_to :order, inverse_of: :payment_orders

  validates :payment_id, uniqueness: { scope: :order_id }
end
