class Table < ApplicationRecord
  has_many :orders, dependent: :destroy, inverse_of: :table
  has_many :calls, dependent: :destroy, inverse_of: :table

  enum access_mode: { pin_required: 0, open_access: 1 }

  has_secure_password :pin, validations: false

  validates :number, presence: true, uniqueness: true
  validates :token, presence: true, uniqueness: true
  validates :access_mode, presence: true

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  before_validation :ensure_token, on: :create

  def rotate_token!
    update!(
      token: SecureRandom.urlsafe_base64(24),
      token_expires_at: nil,
      active: false
    )
  end

  def activate!(expires_at: nil)
    update!(active: true, token_expires_at: expires_at)
  end

  def find_or_create_open_order!
    ApplicationRecord.transaction do
      open_order = orders.open.first
      return open_order if open_order

      if orders.where(status: :open).exists?
        return orders.open.first
      end

      orders.create!(status: :open)
    end
  end

  def generate_pin!
    pin = format("%04d", SecureRandom.random_number(10_000))
    update!(pin: pin, pin_rotated_at: Time.current)
    pin
  end

  def pin_valid?(value)
    return true if open_access?
    return false if value.blank?

    !!authenticate_pin(value)
  end

  private

  def ensure_token
    self.token ||= SecureRandom.urlsafe_base64(24)
  end
end
