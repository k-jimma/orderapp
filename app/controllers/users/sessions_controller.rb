class Users::SessionsController < Devise::SessionsController
  # POST /users/guest_sign_in
  def guest
    user = User.find_or_create_by!(email: "guest@example.com") do |u|
      u.password = SecureRandom.hex(16)
      u.name = "Guest"
      u.role = :staff
    end

    # 毎回パスワードを更新して他経路からのログインを防ぐ
    user.update!(password: SecureRandom.hex(16))

    sign_in(user)
    redirect_to staff_root_path, notice: "ゲストユーザーとしてログインしました"
  end
end
