module Customer
  class BaseController < ApplicationController
    before_action :load_table
    before_action :ensure_table_active!

    include TableTokenAuth

    layout "table"

    private

    def find_or_create_open_order!
      current_table.find_or_create_open_order!
    end

    def load_table
      @table = Table.find_by!(token: params[:token])
      @table.touch(:last_used_at) rescue nil
    end

    def staff_preview?
      params[:staff].present?
    end

    def ensure_table_active!
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
      return if @table.active?
      if billing_in_progress?(@table)
        render "customer/shared/table_billing", status: :locked
        return
      end

      @table.update!(active: true)
    end

    def billing_in_progress?(table)
      table.orders.where(status: :billing).exists?
    end
  end
end
