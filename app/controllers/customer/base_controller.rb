module Customer
  class BaseController < ApplicationController
    before_action :load_table
    before_action :ensure_table_active!

    include TableTokenAuth

    layout "table"

    private

    def find_or_create_open_order!
      # テーブルごとの受付中注文を取得（なければ作成）
      current_table.find_or_create_open_order!
    end

    def load_table
      # トークンからテーブルを取得
      @table = Table.find_by!(token: params[:token])
      # 閲覧のタイムスタンプ更新は失敗しても画面表示を続ける
      @table.touch(:last_used_at) rescue nil
    end

    def staff_preview?
      # スタッフが顧客画面を確認するためのプレビューフラグ
      params[:staff].present?
    end

    def ensure_table_active!
      # テーブルが非アクティブの場合、アクティブ化または専用画面を表示
      return if @table.active?

      if billing_in_progress?(@table)
        render "customer/shared/table_billing", status: :locked
        return
      end

      if staff_preview?
        render "customer/table_statuses/inactive", status: :locked
      else
        @table.update!(active: true, last_used_at: Time.current)
      end
    end

    def ensure_table_active_for_customer!
      # テーブルが非アクティブの場合、アクティブ化または専用画面を表示
      return if @table.active?
      if billing_in_progress?(@table)
        render "customer/shared/table_billing", status: :locked
        return
      end

      @table.update!(active: true)
    end

    def billing_in_progress?(table)
      # テーブルに対して請求中の注文が存在するか確認
      table.orders.where(status: :billing).exists?
    end
  end
end
