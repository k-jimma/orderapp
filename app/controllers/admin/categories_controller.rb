module Admin
  class CategoriesController < BaseController
    before_action :set_category, only: [ :edit, :update, :destroy ]
    before_action :load_parent_options, only: [ :new, :edit, :create, :update ]

    def index
      # 階層構造でカテゴリを取得
      @categories = Category.where(parent_id: nil).includes(:children).order(:sort_order, :name)
    end

    def new
      # 新しいカテゴリを作成
      @category = Category.new
    end

    def create
      # カテゴリを保存
      @category = Category.new(category_params)
      if @category.save
        # 保存成功時は一覧へリダイレクト
        redirect_to admin_categories_path, notice: "カテゴリを作成しました"
      else
        # 保存失敗時は新規作成画面を再表示
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      # カテゴリを更新
      if @category.update(category_params)
        redirect_to admin_categories_path, notice: "カテゴリを更新しました"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      # カテゴリを削除
      @category.destroy
      redirect_to admin_categories_path, notice: "カテゴリを削除しました"
    rescue StandardError => e
      redirect_to admin_categories_path, alert: e.message
    end

    private

    def set_category
      # カテゴリを設定
      @category = Category.find(params[:id])
    end

    def category_params
      # 許可されたパラメータを取得
      params.require(:category).permit(:name, :parent_id, :sort_order)
    end

    def load_parent_options
      # 親カテゴリ選択肢（自身は除外）
      @parent_options = Category.parent_options(except: @category)
    end
  end
end
