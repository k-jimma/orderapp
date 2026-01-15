module Admin
  class TablesController < BaseController
    def index
      # テーブル一覧と新規作成用オブジェクトの準備
      @tables = Table.order(:number)
      @settings = AppSetting.instance
      @table = Table.new(access_mode: @settings.default_access_mode)
    end

    def update
      # テーブル情報の更新
      settings = AppSetting.instance
      table = Table.find(params[:id])
      table_attributes = table_params
      # 全体設定があればアクセスモードを上書き
      table_attributes[:access_mode] = settings.global_access_mode if settings.global_access_mode.present?
      # トークン期限が無効なら強制クリア
      table_attributes[:token_expires_at] = nil unless settings.token_expiry_enabled?
      table.update!(table_attributes)
      flash.now[:notice] = "更新しました"
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              ActionView::RecordIdentifier.dom_id(table),
              partial: "admin/tables/table_row",
              locals: { table: table, settings: settings }
            ),
            turbo_stream.replace("flash", partial: "shared/flash")
          ]
        end
        format.html { redirect_to admin_tables_path, notice: "更新しました" }
      end
    rescue StandardError => e
      flash.now[:alert] = e.message
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash")
        end
        format.html { redirect_to admin_tables_path, alert: e.message }
      end
    end

    def create
      # 新規テーブルの作成
      settings = AppSetting.instance
      table_attributes = table_params
      table_attributes[:access_mode] =
        if settings.global_access_mode.present?
          settings.global_access_mode
        else
          table_attributes[:access_mode].presence || settings.default_access_mode
        end
      table_attributes[:token_expires_at] = nil unless settings.token_expiry_enabled?
      table = Table.new(table_attributes)
      table.save!
      @tables = Table.order(:number)
      @table = Table.new(access_mode: settings.default_access_mode)
      flash.now[:notice] = "テーブルを作成しました"
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(
              "admin_tables_body",
              partial: "admin/tables/table_body",
              locals: { tables: @tables, settings: settings }
            ),
            turbo_stream.replace(
              "table_create_form",
              partial: "admin/tables/table_create_form",
              locals: { table: @table, settings: settings }
            ),
            turbo_stream.replace("flash", partial: "shared/flash")
          ]
        end
        format.html { redirect_to admin_tables_path, notice: "テーブルを作成しました" }
      end
    rescue StandardError => e
      flash.now[:alert] = e.message
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash")
        end
        format.html { redirect_to admin_tables_path, alert: e.message }
      end
    end

    def generate_pin
      # 個別にPINを生成して表示
      table = Table.find(params[:id])
      generated_pin = table.generate_pin!
      redirect_to admin_tables_path, notice: "PINを生成しました(テーブル#{table.number}):#{generated_pin}"
    end

    def generate_pin_bulk
      # 全テーブルのPINを一括生成・更新
      pin_value = params[:pin].presence || format("%04d", SecureRandom.random_number(10_000))
      Table.order(:number).find_each do |table|
        table.update!(pin: pin_value, pin_rotated_at: Time.current)
      end
      settings = AppSetting.instance
      settings.update!(common_pin: pin_value)
      flash.now[:notice] = "全テーブルのPINを更新しました（共通PIN: #{pin_value}）"
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "common_pin_display",
              partial: "admin/tables/common_pin_badge",
              locals: { settings: settings }
            ),
            turbo_stream.replace("flash", partial: "shared/flash")
          ]
        end
        format.html { redirect_to admin_tables_path, notice: "全テーブルのPINを更新しました（共通PIN: #{pin_value}）" }
      end
    end

    def activate_all
      # 全テーブルを有効化
      Table.update_all(active: true)
      settings = AppSetting.instance
      @tables = Table.order(:number)
      flash.now[:notice] = "全テーブルを有効化しました"
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(
              "admin_tables_body",
              partial: "admin/tables/table_body",
              locals: { tables: @tables, settings: settings }
            ),
            turbo_stream.replace("flash", partial: "shared/flash")
          ]
        end
        format.html { redirect_to admin_tables_path, notice: "全テーブルを有効化しました" }
      end
    end

    def deactivate_all
      # 全テーブルを無効化
      Table.update_all(active: false)
      settings = AppSetting.instance
      @tables = Table.order(:number)
      flash.now[:notice] = "全テーブルを無効化しました"
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(
              "admin_tables_body",
              partial: "admin/tables/table_body",
              locals: { tables: @tables, settings: settings }
            ),
            turbo_stream.replace("flash", partial: "shared/flash")
          ]
        end
        format.html { redirect_to admin_tables_path, notice: "全テーブルを無効化しました" }
      end
    end

    private

    def table_params
      # テーブル作成・更新用パラメータの許可
      params.require(:table).permit(:number, :access_mode, :active, :token_expires_at)
    end
  end
end
