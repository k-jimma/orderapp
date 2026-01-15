class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :trackable

  # admin/staff/chief は管理系ロール
  enum role: { admin: 0, staff: 1, chief: 2 }

  validates :name, presence: true
  validates :role, presence: true

  def guest?
    # ゲストユーザーかどうかを確認
    email == "guest@example.com"
  end

  def initial_password_present?
    # 初期パスワードが設定されており、まだ変更されていないかどうか
    initial_password_ciphertext.present? && initial_password_changed_at.nil?
  end

  def initial_password_plaintext
    # 初期パスワードの復号化を試みる
    return nil if initial_password_ciphertext.blank?
    encryptor.decrypt_and_verify(initial_password_ciphertext)
  rescue
    nil
  end

  def set_initial_password!(plaintext_password)
    # 初期パスワードを暗号化して保存
    self.initial_password_ciphertext = encryptor.encrypt_and_sign(plaintext_password)
    self.initial_password_set_at = Time.current
    self.initial_password_changed_at = nil
  end

  def mark_initial_password_changed!
    # 初期パスワードが変更されたことを記録
    timestamp = Time.current
    update!(
      initial_password_ciphertext: nil,
      initial_password_changed_at: timestamp,
      force_password_change: false,
      password_changed_at: timestamp
    )
  end

  # 初期パスワードを見せてよい期間
  INITIAL_PASSWORD_VISIBLE_FOR = 24.hours

  def initial_password_visible?
    # 初期パスワードを表示してよい期間内かどうか
    return false unless initial_password_present?
    return false if initial_password_set_at.blank?
    initial_password_set_at >= INITIAL_PASSWORD_VISIBLE_FOR.ago
  end

  private

  def encryptor
    # 初期パスワードの暗号化/復号化用のMessageEncryptorを取得
    key = ENV["INITIAL_PASSWORD_ENCRYPTION_KEY"].presence ||
          Rails.application.credentials.password_encryption_key

    raise "missing INITIAL_PASSWORD_ENCRYPTION_KEY" if key.blank?

    secret = ActiveSupport::KeyGenerator.new(key).generate_key("initial_password", 32)
    ActiveSupport::MessageEncryptor.new(secret)
  end
end
