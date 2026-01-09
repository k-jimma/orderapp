module Admin
  class TablesController < BaseController
    def index
      @tables = Table.order(:number)
      @settings = AppSetting.instance
      @table = Table.new(access_mode: @settings.default_access_mode)
    end

    def update
      settings = AppSetting.instance
      table = Table.find(params[:id])
      attrs = table_params
      attrs[:access_mode] = settings.global_access_mode if settings.global_access_mode.present?
      attrs[:token_expires_at] = nil unless settings.token_expiry_enabled?
      table.update!(attrs)
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
      settings = AppSetting.instance
      attrs = table_params
      attrs[:access_mode] =
        if settings.global_access_mode.present?
          settings.global_access_mode
        else
          attrs[:access_mode].presence || settings.default_access_mode
        end
      attrs[:token_expires_at] = nil unless settings.token_expiry_enabled?
      table = Table.new(attrs)
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
      table = Table.find(params[:id])
      pin = table.generate_pin!
      redirect_to admin_tables_path, notice: "PINを生成しました(テーブル#{table.number}):#{pin}"
    end

    def generate_pin_bulk
      pin_value = params[:pin].presence || format("%04d", SecureRandom.random_number(10_000))
      Table.order(:number).find_each do |t|
        t.update!(pin: pin_value, pin_rotated_at: Time.current)
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
      params.require(:table).permit(:number, :access_mode, :active, :token_expires_at)
    end
  end
end
