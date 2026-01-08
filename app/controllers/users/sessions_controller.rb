class Users::SessionsController < Devise::SessionsController
  def guest
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
end
