class Users::PasswordsController < Devise::PasswordsController
  def new
    redirect_to user_request_access_path
  end
end
