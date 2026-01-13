class Users::SessionsController < Devise::SessionsController
  def guest
    return redirect_to new_user_session_path, alert: "ゲストログインは現在無効です" unless guest_logins_enabled?

    raw = SecureRandom.hex(16)

    user = User.find_or_create_by!(email: "guest@example.com") do |u|
      u.password = raw
      u.password_confirmation = raw
      u.name = "Guest"
      u.role = :staff
      u.force_password_change = false
      u.initial_password_ciphertext = nil
      u.initial_password_set_at = nil
      u.initial_password_changed_at = Time.current
    end

    user.update!(
      password: raw,
      password_confirmation: raw,
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
    return redirect_to new_user_session_path, alert: "ゲストログインは現在無効です" unless guest_logins_enabled?

    raw = SecureRandom.hex(16)

    user = User.find_or_create_by!(email: "guest-admin@example.com") do |u|
      u.password = raw
      u.password_confirmation = raw
      u.name = "Guest Admin"
      u.role = :admin
      u.force_password_change = false
      u.initial_password_ciphertext = nil
      u.initial_password_set_at = nil
      u.initial_password_changed_at = Time.current
    end

    user.update!(
      password: raw,
      password_confirmation: raw,
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
    AppSetting.instance.guest_logins_enabled?
  end
end
