require "rqrcode"
require "rqrcode_png"
require "chunky_png"
require "zip"

module Admin
  class TableMaintenanceController < BaseController
    def index
      # テーブル一覧の取得
      @tables = Table.order(:number)
    end

    def update_number
      # テーブル番号の更新
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
      # テーブルトークンの再生成
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
      # テーブルの削除
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

    def qr
      # 個別にQRを作成して返す
      table = Table.find(params[:id])
      qr_png = qr_png_for(table)
      send_qr_data(qr_png, "テーブル#{table.number}_tableQR.png")
    end

    def qr_bulk
      # まとめてQRを作成してzipで返す
      pngs = Table.order(:number).map do |table|
        [ table, qr_png_for(table) ]
      end

      zip_data = Zip::OutputStream.write_buffer do |zip|
        pngs.each do |table, png|
          zip.put_next_entry("テーブル#{table.number}_tableQR.png")
          zip.write(png)
        end
      end
      zip_data.rewind

      send_data zip_data.read,
        type: "application/zip",
        disposition: "attachment",
        filename: "table_qr_codes.zip"
    end

    private

    def table_number_params
      # テーブル番号更新用パラメータの許可
      params.require(:table).permit(:number)
    end

    def ensure_table_safe_for_admin_change!(table)
      # 営業中や未会計がある場合は変更禁止
      raise "操作するには先に無効化してください" if table.active?
      if table.orders.where(status: [ :open, :billing ]).exists?
        raise "未会計の注文があるため操作できません"
      end
    end

    def qr_png_for(table)
      # テーブル用QRコードPNGデータの生成
      url = table_items_url(token: table.token, host: request.base_url)
      RQRCode::QRCode.new(url).as_png(
        size: 300,
        border_modules: 2,
        color: ChunkyPNG::Color::BLACK,
        fill: ChunkyPNG::Color::WHITE
      ).to_blob
    end

    def send_qr_data(png, filename)
      # QRコードPNGデータの送信
      disposition = params[:download].present? ? "attachment" : "inline"
      send_data png,
        type: "image/png",
        disposition: disposition,
        filename: filename
    end
  end
end
