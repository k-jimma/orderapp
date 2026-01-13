module Customer
  class TableStatusesController < BaseController
    skip_before_action :set_current_table, only: [ :activate ]
    skip_before_action :ensure_table_active!, only: [ :activate ]

    def activate
      Rails.logger.info("[activate] before: table=#{@table.id} active=#{@table.active}")
      if billing_in_progress?(@table)
        redirect_to table_items_path(token: @table.token, staff: params[:staff]),
                    alert: "会計中のため有効化できません。"
        return
      end

      @table.update!(active: true, last_used_at: Time.current)
      Rails.logger.info("[activate] after: table=#{@table.id} active=#{@table.reload.active}")
      redirect_to table_items_path(token: @table.token, staff: params[:staff]),
                  notice: "テーブルを有効化しました。"
    end
  end
end
