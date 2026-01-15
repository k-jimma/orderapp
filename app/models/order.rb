class Order < ApplicationRecord
  belongs_to :table, inverse_of: :orders

  has_many :order_items, dependent: :destroy, inverse_of: :order
  has_many :payment_orders, dependent: :destroy, inverse_of: :order
  has_many :payments, through: :payment_orders

  # open: 注文受付中 / billing: 会計処理中 / closed: 会計済み
  enum status: { open: 0, billing: 1, closed: 2 }

  validates :status, presence: true
  validate :only_one_open_per_table, on: :create

  def subtotal
    # キャンセル済み明細は合計から除外する
    order_items.where.not(status: :canceled).sum(Arel.sql("quantity * unit_price"))
  end

  def refresh_cached_total!
    # cached_total は現在の明細から再計算した小計（キャンセル除外）
    update!(cached_total: subtotal)
  end

  def start_billing!
    # 受付中以外は会計開始できない
    raise OrderClosedError, "受付中以外は会計開始できません" unless open?
    update!(status: :billing)
  end

  def close!(closed_time: Time.current)
    # 会計処理中以外は会計済みにできない
    update!(status: :closed, closed_at: closed_time)
  end

  def ensure_open!
    # 受付中でない場合は例外を発生させる
    raise OrderClosedError, "会計処理中または会計済みのため注文できません" unless open?
  end

  class OrderClosedError < StandardError; end

  private

  def only_one_open_per_table
    # 同じテーブルに受付中の注文が既に存在する場合はエラーを追加
    return unless table && open?
    if table.orders.where(status: :open).exists?
      errors.add(:base, "このテーブルには既に受付中の注文が存在します")
    end
  end
end
