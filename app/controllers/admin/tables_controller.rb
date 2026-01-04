module Admin
  class TablesController < BaseController
    def index
      @tables = Table.order(:number)
    end

    def update
      table = Table.find(params[:id])
      table.update!(table_params)
      redirect_to admin_tables_path, notice: "更新しました"
    rescue StandardError => e
      redirect_to admin_tables_path, alert: e.message
    end

    def generate_pin
      table = Table.find(params[:id])
      pin = table.generate_pin!
      redirect_to admin_tables_path, notice: "PINを生成しました(テーブル#{table.number}):#{pin}"
    end

    def generate_pin_bulk
      Table.order(:number).find_each(&:generate_pin!)
      redirect_to admin_tables_path, notice: "全テーブルのPINを更新しました"
    end

    private

    def table_params
      params.require(:table).permit(:access_mode, :active, :token_expires_at)
    end
  end
end
