class OrderItem < ApplicationRecord
  belongs_to :order, inverse_of: :order_items
  belongs_to :item, inverse_of: :order_items

  # new: 受付 / cooking: 調理中 / ready: 提供待ち / served: 提供済み / canceled: キャンセル
  enum status: {
    new: 0,
    cooking: 1,
    ready: 2,
    served: 3,
    canceled: 9
  }, _prefix: true

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :copy_unit_price_from_item, on: :create

  # 進行中の明細（提供済み・キャンセルは除外）
  scope :progressing, -> { where(status: [ statuses[:new], statuses[:cooking], statuses[:ready] ]) }

  def cancel!
    # 明細をキャンセル状態に変更
    update!(status: :canceled)
  end

  def transition_to!(next_status)
    # 明細の状態を遷移させる
    next_status = next_status.to_sym

    allowed_transitions = {
      new: [ :cooking, :canceled ],
      cooking: [ :ready, :canceled ],
      ready: [ :served, :canceled ],
      served: [],
      canceled: []
    }

    current_status = status.to_sym
    unless allowed_transitions[current_status].include?(next_status)
      current_label = self.class.status_label(current_status)
      next_label = self.class.status_label(next_status)
      raise InvalidTransitionError, "#{current_label} から #{next_label} へは変更できません"
    end

    update!(status: next_status)
  end

  class InvalidTransitionError < StandardError; end

  def self.status_label(status)
    # ステータスのラベルを取得
    I18n.t("enums.order_item.status.#{status}", default: status.to_s)
  end

  private

  def copy_unit_price_from_item
    # item の価格を単価としてコピー
    self.unit_price ||= item&.price
  end
end
