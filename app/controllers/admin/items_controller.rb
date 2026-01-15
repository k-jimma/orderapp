module Admin
  class ItemsController < BaseController
    before_action :set_item, only: [ :edit, :update, :destroy ]

    def index
      # 商品一覧を取得
      @items = Item.includes(:category).order(:id)
    end

    def new
      # 新しい商品を作成
      @item = Item.new
      load_categories_for_form
    end

    def create
      # 商品を保存
      @item = Item.new(item_params)
      if @item.save
        redirect_to admin_items_path, notice: "商品を登録しました"
      else
        load_categories_for_form
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      # 商品編集
      load_categories_for_form
    end

    def update
      # 商品を更新
      if @item.update(item_params)
        redirect_to admin_items_path, notice: "商品を更新しました"
      else
        load_categories_for_form
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      # 商品を削除
      @item.destroy
      redirect_to admin_items_path, notice: "商品を削除しました"
    rescue StandardError => e
      redirect_to admin_items_path, alert: e.message
    end

    private

    def set_item
      # 商品を設定
      @item = Item.find(params[:id])
    end

    def load_categories_for_form
      # フォームのカテゴリ選択肢
      @categories = Category.order(:id)
    end

    def item_params
      # 許可されたパラメータを取得
      params.require(:item).permit(:name, :price, :category_id, :is_available)
    end
  end
end
