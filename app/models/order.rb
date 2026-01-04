class Order < ApplicationRecord
  belongs_to :table, inverse_of: :orders

  has_many :order_items, dependent: :destroy, inverse_of: :order
  has_many :payment_orders, dependent: :destroy, inverse_of: :order
  has_many :payments, through: :payment_orders

  enum status: { open: 0, billing: 1, closed: 2 }

  validates :status, presence: true
  validate :only_one_open_per_table, on: :create

  def subtotal
    order_items.where.not(status: :canceled).sum("quantity * unit_price")
  end

  def refresh_cached_total!
    update!(cached_total: subtotal)
  end

  def start_billing!
    raise "open以外は会計開始できません" unless open?
    update!(status: :billing)
  end

  def close!(closed_time: Time.current)
    update!(status: :closed, closed_at: closed_time)
  end

  def ensure_open!
    raise OrderClosedError, "会計処理中または会計済みのため注文できません" unless open?
  end

  class OrderClosedError < StandardError; end

  private

  def only_one_open_per_table
    return unless table && status.to_s == "open"
    if table.orders.where(status: :open).exists?
      errors.add(:base, "このテーブルには既にopenの注文が存在します")
    end
  end
end
