module Admin
  class ItemsController < BaseController
    before_action :set_item, only: [ :edit, :update, :destroy ]

    def index
      @items = Item.includes(:category).order(:id)
    end

    def new
      @item = Item.new
      load_categories
    end

    def create
      @item = Item.new(item_params)
      if @item.save
        redirect_to admin_items_path, notice: "商品を登録しました"
      else
        load_categories
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      load_categories
    end

    def update
      if @item.update(item_params)
        redirect_to admin_items_path, notice: "商品を更新しました"
      else
        load_categories
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @item.destroy
      redirect_to admin_items_path, notice: "商品を削除しました"
    rescue StandardError => e
      redirect_to admin_items_path, alert: e.message
    end

    private

    def set_item
      @item = Item.find(params[:id])
    end

    def load_categories
      @categories = Category.order(:id)
    end

    def item_params
      params.require(:item).permit(:name, :price, :category_id, :is_available)
    end
  end
end
