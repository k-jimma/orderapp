module Staff
  class PasswordsController < BaseController
    def edit
    end

    def update
      # 現在のスタッフユーザーを取得
      staff_user = current_user

      unless staff_user.update(password_params)
        flash.now[:alert] = staff_user.errors.full_messages.to_sentence
        return render :edit, status: :unprocessable_entity
      end

      staff_user.mark_initial_password_changed!

      redirect_to staff_root_path, notice: "パスワードを変更しました"
    end

    private

    def password_params
      # 強く許可するパラメータを指定
      params.require(:user).permit(:password, :password_confirmation)
    end
  end
end
