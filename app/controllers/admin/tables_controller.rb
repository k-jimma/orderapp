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
      redirect_to admin_tables_path, notice: "更新しました"
    rescue StandardError => e
      redirect_to admin_tables_path, alert: e.message
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
      redirect_to admin_tables_path, notice: "テーブルを作成しました"
    rescue StandardError => e
      redirect_to admin_tables_path, alert: e.message
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
      redirect_to admin_tables_path, notice: "全テーブルのPINを更新しました（共通PIN: #{pin_value}）"
    end

    def activate_all
      Table.update_all(active: true)
      redirect_to admin_tables_path, notice: "全テーブルを有効化しました"
    end

    private

    def table_params
      params.require(:table).permit(:number, :access_mode, :active)
    end
  end
end
