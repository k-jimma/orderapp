module Admin
  class TableMaintenanceController < BaseController
    def index
      @tables = Table.order(:number)
    end

    def update_number
      table = Table.find(params[:id])
      table.update!(table_number_params)
      flash.now[:notice] = "テーブル番号を更新しました"
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(ActionView::RecordIdentifier.dom_id(table),
                                 partial: "admin/table_maintenance/table_row",
                                 locals: { table: table }),
            turbo_stream.replace("flash", partial: "shared/flash")
          ]
        end
        format.html { redirect_to admin_table_maintenance_index_path, notice: "テーブル番号を更新しました" }
      end
    rescue StandardError => e
      flash.now[:alert] = e.message
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash") }
        format.html { redirect_to admin_table_maintenance_index_path, alert: e.message }
      end
    end

    def rotate_token
      table = Table.find(params[:id])
      ensure_table_safe_for_admin_change!(table)
      table.rotate_token!
      flash.now[:notice] = "トークンを再生成しました（テーブル#{table.number}）"
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(ActionView::RecordIdentifier.dom_id(table),
                                 partial: "admin/table_maintenance/table_row",
                                 locals: { table: table }),
            turbo_stream.replace("flash", partial: "shared/flash")
          ]
        end
        format.html { redirect_to admin_table_maintenance_index_path, notice: "トークンを再生成しました（テーブル#{table.number}）" }
      end
    rescue StandardError => e
      flash.now[:alert] = e.message
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash") }
        format.html { redirect_to admin_table_maintenance_index_path, alert: e.message }
      end
    end

    def destroy
      table = Table.find(params[:id])
      ensure_table_safe_for_admin_change!(table)
      table.destroy!
      flash.now[:notice] = "テーブルを削除しました"
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove(ActionView::RecordIdentifier.dom_id(table)),
            turbo_stream.replace("flash", partial: "shared/flash")
          ]
        end
        format.html { redirect_to admin_table_maintenance_index_path, notice: "テーブルを削除しました" }
      end
    rescue StandardError => e
      flash.now[:alert] = e.message
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash") }
        format.html { redirect_to admin_table_maintenance_index_path, alert: e.message }
      end
    end

    private

    def table_number_params
      params.require(:table).permit(:number)
    end

    def ensure_table_safe_for_admin_change!(table)
      raise "操作するには先に無効化してください" if table.active?
      if table.orders.where(status: [ :open, :billing ]).exists?
        raise "未会計の注文があるため操作できません"
      end
    end
  end
end
