module Staff
  class PasswordsController < BaseController
    def edit
    end

    def update
      user = current_user

      unless user.update(password_params)
        flash.now[:alert] = user.errors.full_messages.to_sentence
        return render :edit, status: :unprocessable_entity
      end

      user.mark_initial_password_changed!

      redirect_to staff_root_path, notice: "パスワードを変更しました"
    end

    private

    def password_params
      params.require(:user).permit(:password, :password_confirmation)
    end
  end
end
