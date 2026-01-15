class Table < ApplicationRecord
  has_many :orders, dependent: :destroy, inverse_of: :table
  has_many :calls, dependent: :destroy, inverse_of: :table

  # pin_required: PIN必須 / open_access: PIN不要
  enum access_mode: { pin_required: 0, open_access: 1 }

  has_secure_password :pin, validations: false

  validates :number, presence: true, uniqueness: true
  validates :token, presence: true, uniqueness: true
  validates :access_mode, presence: true

  # 稼働中/停止中の絞り込み
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :portfolio, -> { where(portfolio: true) }

  def inactive?
    # 稼働中でないことを確認
    !active?
  end

  before_validation :ensure_token, on: :create

  def rotate_token!
    # トークンを新規生成し、稼働停止状態にする
    update!(
      token: SecureRandom.urlsafe_base64(24),
      token_expires_at: nil,
      active: false
    )
  end

  def activate!(expires_at: nil)
    # 稼働状態にし、必要に応じてトークン有効期限を設定
    update!(active: true, token_expires_at: expires_at)
  end

  def find_or_create_open_order!
    # 受付中の注文を取得、なければ新規作成する
    ApplicationRecord.transaction do
      existing_open_order = orders.open.first
      return existing_open_order if existing_open_order

      if orders.where(status: :open).exists?
        return orders.open.first
      end

      orders.create!(status: :open)
    end
  end

  def generate_pin!
    # 4桁のPINを新規生成して保存
    generated_pin = format("%04d", SecureRandom.random_number(10_000))
    update!(pin: generated_pin, pin_rotated_at: Time.current)
    generated_pin
  end

  def pin_valid?(value)
    # PINが有効かどうかを確認
    return true if open_access?
    return false if value.blank?

    !!authenticate_pin(value)
  end

  private

  def ensure_token
    # URL向けの一意トークンが未設定の場合のみ生成
    self.token ||= SecureRandom.urlsafe_base64(24)
  end
end
