class Users::SessionsController < Devise::SessionsController
  def new
    # ポートフォリオテーブル一覧を取得
    @portfolio_tables = Table.portfolio.order(:number)
    super
  end

  def guest
    # ゲストログイン(スタッフ権限)が有効か確認
    return redirect_to new_user_session_path, alert: "ゲストログインは現在無効です" unless guest_logins_enabled?

    raw_password = SecureRandom.hex(16)

    user = User.find_or_create_by!(email: "guest@example.com") do |u|
      u.password = raw_password
      u.password_confirmation = raw_password
      u.name = "Guest"
      u.role = :staff
      u.force_password_change = false
      u.initial_password_ciphertext = nil
      u.initial_password_set_at = nil
      u.initial_password_changed_at = Time.current
    end

    user.update!(
      password: raw_password,
      password_confirmation: raw_password,
      force_password_change: false,
      initial_password_ciphertext: nil,
      initial_password_set_at: nil,
      initial_password_changed_at: Time.current,
      password_changed_at: Time.current
    )

    sign_in(user)
    redirect_to staff_root_path, notice: "ゲストユーザーとしてログインしました"
  end

  def guest_admin
    # ゲストログイン(管理者権限)が有効か確認
    return redirect_to new_user_session_path, alert: "ゲストログインは現在無効です" unless guest_logins_enabled?

    raw_password = SecureRandom.hex(16)

    user = User.find_or_create_by!(email: "guest-admin@example.com") do |u|
      u.password = raw_password
      u.password_confirmation = raw_password
      u.name = "Guest Admin"
      u.role = :admin
      u.force_password_change = false
      u.initial_password_ciphertext = nil
      u.initial_password_set_at = nil
      u.initial_password_changed_at = Time.current
    end

    user.update!(
      password: raw_password,
      password_confirmation: raw_password,
      force_password_change: false,
      initial_password_ciphertext: nil,
      initial_password_set_at: nil,
      initial_password_changed_at: Time.current,
      password_changed_at: Time.current
    )

    sign_in(user)
    redirect_to staff_root_path, notice: "ゲスト管理者としてログインしました"
  end

  private

  def guest_logins_enabled?
    # ゲストログインが有効かどうかを確認
    AppSetting.instance.guest_logins_enabled?
  end
end
