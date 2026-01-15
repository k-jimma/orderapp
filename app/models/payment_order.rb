class PaymentOrder < ApplicationRecord
  belongs_to :payment, inverse_of: :payment_orders
  belongs_to :order, inverse_of: :payment_orders

  # 同じ支払いに同じ注文を二重に紐付けない
  validates :payment_id, uniqueness: { scope: :order_id }
end
