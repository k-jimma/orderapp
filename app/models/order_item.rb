class OrderItem < ApplicationRecord
  belongs_to :order, inverse_of: :order_items
  belongs_to :item, inverse_of: :order_items

  enum status: {
    new: 0,
    cooking: 1,
    ready: 2,
    served: 3,
    canceled: 9
  }

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :copy_unit_price_from_item, on: :create

  scope :progressing, -> { where(status: [statuses[:new], statuses[:cooking], statuses[:ready]]) }

  def cancel!
    update!(status: :canceled)
  end

  def transition_to!(next_status)
    next_status = next_status.to_sym

    allowed = {
      new: [:cooking, :canceled],
      cooking: [:ready, :canceled],
      ready: [:served, :canceled],
      served: [],
      canceled: []
    }

    current = status.to_sym
    unless allowed[current].include?(next_status)
      raise InvalidTransitionError, "#{current} から #{next_status} へは変更できません"
    end

    update!(status: next_status)
  end

  class InvalidTransitionError < StandardError; end

  private

  def copy_unit_price_from_item
    self.unit_price ||= item&.price
  end
end
