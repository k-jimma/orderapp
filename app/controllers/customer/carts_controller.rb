module Customer
  class CartsController < BaseController
    before_action :ensure_cart_table_scope!

    def show
      load_cart_view!
    end

    def add
      item_id = params.require(:item_id).to_i
      qty = params[:quantity].presence&.to_i || 1
      note = params[:note].to_s

      entry = cart_items.find { |x| x["item_id"] == item_id }
      if entry
        entry["qty"] += qty
        entry["note"] = note if note.present?
      else
        cart_items << { "item_id" => item_id, "qty" => qty, "note" => note }
      end

      save_cart!
      load_cart_view!

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to table_cart_path(token: @table.token, staff: params[:staff]), notice: "カートに追加しました" }
      end
    end

    def update_item
      item_id = params.require(:item_id).to_i
      note = params[:note].to_s

      entry = cart_items.find { |x| x["item_id"] == item_id }
      unless entry
        respond_to do |format|
          format.turbo_stream do
            flash.now[:alert] = "対象の商品が見つかりません"
            load_cart_view!
          end
          format.html { redirect_to table_cart_path(token: @table.token, staff: params[:staff]), alert: "対象の商品が見つかりません" }
        end
        return
      end

      qty =
        if params.key?(:quantity) && params[:quantity].present?
          params[:quantity].to_i
        else
          entry["qty"].to_i
        end

      if qty <= 0
        cart_items.delete(entry)
      else
        entry["qty"] = qty
        entry["note"] = note
      end

      save_cart!
      load_cart_view!

      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = "更新しました"
        end
        format.html { redirect_to table_cart_path(token: @table.token, staff: params[:staff]), notice: "更新しました" }
      end
    end

    def remove_item
      item_id = params.require(:item_id).to_i
      cart_items.reject! { |x| x["item_id"] == item_id }
      save_cart!
      load_cart_view!

      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = "削除しました"
        end
        format.html { redirect_to table_cart_path(token: @table.token, staff: params[:staff]), notice: "削除しました" }
      end
    end

    def clear
      session.delete(:cart)
      load_cart_view!

      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = "カートを空にしました"
        end
        format.html { redirect_to table_cart_path(token: @table.token, staff: params[:staff]), notice: "カートを空にしました" }
      end
    end

    def checkout
      if billing_in_progress?(@table)
        render "customer/shared/table_billing", status: :locked
        return
      end

      @order = find_or_create_open_order!
      items = cart_items.dup

      if items.empty?
        redirect_to table_cart_path(token: @table.token, staff: params[:staff]), alert: "カートが空です"
        return
      end

      ActiveRecord::Base.transaction do
        items.each do |x|
          Orders::AddItem.new(
            order: @order,
            item_id: x["item_id"],
            quantity: x["qty"],
            note: x["note"]
          ).call!
        end
      end

      session.delete(:cart)
      redirect_to table_order_path(token: @table.token, staff: params[:staff]), notice: "注文を確定しました"
    rescue StandardError => e
      redirect_to table_cart_path(token: @table.token, staff: params[:staff]), alert: e.message
    end

    private

    def ensure_cart_table_scope!
      c = session[:cart]
      return if c.blank?

      if c["table_token"].present? && c["table_token"] != @table.token
        session.delete(:cart)
      end
    end

    def cart_items
      session[:cart] ||= { "table_token" => @table.token, "items" => [] }
      session[:cart]["items"] ||= []
      session[:cart]["items"]
    end

    def save_cart!
      session[:cart]["table_token"] = @table.token
      session[:cart]["items"] = cart_items
    end

    def load_cart_view!
      @cart_items = cart_items
      @items_by_id = Item.where(id: @cart_items.map { |x| x["item_id"] }).index_by(&:id)
      @total_price = @cart_items.sum do |ci|
        item = @items_by_id[ci["item_id"]]
        next 0 unless item
        item.price.to_i * ci["qty"].to_i
      end
    end
  end
end
