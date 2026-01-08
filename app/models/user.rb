class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :trackable

  enum role: { admin: 0, staff: 1 }

  validates :name, presence: true
  validates :role, presence: true

  def guest?
    email == "guest@example.com"
  end

  def initial_password_present?
    initial_password_ciphertext.present? && initial_password_changed_at.nil?
  end

  def initial_password_plaintext
    return nil if initial_password_ciphertext.blank?
    encryptor.decrypt_and_verify(initial_password_ciphertext)
  rescue
    nil
  end

  def set_initial_password!(plain)
    self.initial_password_ciphertext = encryptor.encrypt_and_sign(plain)
    self.initial_password_set_at = Time.current
    self.initial_password_changed_at = nil
  end

  def mark_initial_password_changed!
    now = Time.current
    update!(
      initial_password_ciphertext: nil,
      initial_password_changed_at: now,
      force_password_change: false,
      password_changed_at: now
    )
  end

  INITIAL_PASSWORD_VISIBLE_FOR = 24.hours

  def initial_password_visible?
    return false unless initial_password_present?
    return false if initial_password_set_at.blank?
    initial_password_set_at >= INITIAL_PASSWORD_VISIBLE_FOR.ago
  end

  private

  def encryptor
    key = ENV["INITIAL_PASSWORD_ENCRYPTION_KEY"].presence ||
          Rails.application.credentials.password_encryption_key

    raise "missing INITIAL_PASSWORD_ENCRYPTION_KEY" if key.blank?

    secret = ActiveSupport::KeyGenerator.new(key).generate_key("initial_password", 32)
    ActiveSupport::MessageEncryptor.new(secret)
  end
end
