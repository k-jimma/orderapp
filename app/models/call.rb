class Call < ApplicationRecord
  belongs_to :table, inverse_of: :calls

  # kind: 呼出種別 / status: 対応状況
  enum kind: { bill: 0, water: 1, plate: 2 }
  enum status: { open: 0, closed: 1 }

  # 未対応のみ
  scope :open_only, -> { where(status: :open) }

  validates :kind, presence: true
  validates :status, presence: true
end
