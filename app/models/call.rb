class Call < ApplicationRecord
  belongs_to :table, inverse_of: :calls

  enum kind: { bill: 0, water: 1, plate: 2 }
  enum status: { open: 0, closed: 1 }

  scope :open_only, -> { where(status: :open) }

  validates :kind, presence: true
  validates :status, presence: true
end
