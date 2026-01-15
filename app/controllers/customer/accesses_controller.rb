module Customer
  class AccessesController < BaseController
    include TableAccessGuard

    skip_before_action :require_table_access!, only: [ :new, :create ]

    def new
    end

    def create
      # オープンアクセスなら即許可
      if AppSetting.instance.open_access_for?(current_table)
        grant_table_access!
        return redirect_to table_items_path(token: current_table.token)
      end

      entered_pin = params[:pin].to_s
      if current_table.pin_valid?(entered_pin)
        grant_table_access!
        redirect_to table_items_path(token: current_table.token), notice: "認証しました"
      else
        redirect_to new_table_access_path(token: current_table.token), alert: "PINが違います"
      end
    end

    def destroy
      # 認証解除
      revoke_table_access!
      redirect_to new_table_access_path(token: current_table.token), notice: "認証を解除しました"
    end
  end
end
