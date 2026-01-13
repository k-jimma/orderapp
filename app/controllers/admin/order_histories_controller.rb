module Admin
  class OrderHistoriesController < BaseController
    def index
      @tables = Table.order(:number)
      @filters = extract_filters
      filtered = filtered_scope(@filters)

      @total_sales = filtered.sum(:amount)
      @total_count = filtered.count
      @daily_stats = group_stats(filtered, "DATE(paid_at)")
      @monthly_stats = group_stats(filtered, "DATE_TRUNC('month', paid_at)")
      @yearly_stats = group_stats(filtered, "DATE_TRUNC('year', paid_at)")

      @payments = apply_sort(filtered, @filters)
                   .includes(orders: :table)
    end

    def destroy
      payment = Payment.find(params[:id])
      Payment.transaction do
        payment.orders.destroy_all
        payment.destroy!
      end
      flash.now[:notice] = "注文履歴を削除しました"
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove(ActionView::RecordIdentifier.dom_id(payment)),
            turbo_stream.replace("flash", partial: "shared/flash")
          ]
        end
        format.html { redirect_to admin_order_histories_path, notice: "注文履歴を削除しました" }
      end
    rescue StandardError => e
      flash.now[:alert] = e.message
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash") }
        format.html { redirect_to admin_order_histories_path, alert: e.message }
      end
    end

    private

    def extract_filters
      {
        from: parse_date(params[:from]),
        to: parse_date(params[:to]),
        all_dates: params[:all_dates] == "1",
        table_ids: Array(params[:table_ids]).reject(&:blank?),
        sort: params[:sort].presence || "paid_at",
        dir: params[:dir].presence_in(%w[asc desc]) || "desc"
      }
    end

    def filtered_scope(filters)
      scope = Payment.paid.where.not(paid_at: nil)
                     .joins(:orders)
                     .where(orders: { status: Order.statuses[:closed] })
                     .distinct

      unless filters[:all_dates]
        if filters[:from].present?
          scope = scope.where("paid_at >= ?", filters[:from].beginning_of_day)
        end
        if filters[:to].present?
          scope = scope.where("paid_at <= ?", filters[:to].end_of_day)
        end
      end

      if filters[:table_ids].any?
        scope = scope.joins(orders: :table).where(tables: { id: filters[:table_ids] })
      end

      scope
    end

    def apply_sort(scope, filters)
      case filters[:sort]
      when "amount"
        scope.order(amount: filters[:dir])
      when "table_number"
        scope.joins(orders: :table)
             .group("payments.id")
             .order(table_number_order(filters[:dir]))
      else
        scope.order(paid_at: filters[:dir])
      end
    end

    def table_number_order(direction)
      if direction == "asc"
        Arel.sql("MIN(tables.number) ASC")
      else
        Arel.sql("MIN(tables.number) DESC")
      end
    end

    def group_stats(scope, group_sql)
      {
        sales: scope.group(Arel.sql(group_sql)).sum(:amount),
        count: scope.group(Arel.sql(group_sql)).count
      }
    end

    def parse_date(value)
      return nil if value.blank?
      Date.parse(value)
    rescue ArgumentError
      nil
    end
  end
end
