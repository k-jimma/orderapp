module Table
  class AccessesController < BaseController
    include TableAccessGuard

    skip_before_action :require_table_access!, only: [ :new, :create ]

    def new; end

    def create
      if current_table.open_access?
        grant_table_access!
        return redirect_to table_items_path(token: current_table.token)
      end

      pin = params[:pin].to_s
      if current_table.pin_valid?(pin)
        grant_table_access!
        redirect_to table_items_path(token: current_table.token), notice: "認証しました"
      else
        redirect_to table_access_new_path(token: current_table.token), alert: "PINが違います"
      end
    end

    def destroy
      revoke_table_access!
      redirect_to table_access_new_path(token: current_table.token), notice: "認証を解除しました"
    end
  end
end
