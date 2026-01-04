module Admin
  class CategoriesController < BaseController
    before_action :set_category, only: [ :edit, :update, :destroy ]

    def index
      @categories = Category.order(:id)
    end

    def new
      @category = Category.new
    end

    def create
      @category = Category.new(category_params)
      if @category.save
        redirect_to admin_categories_path, notice: "カテゴリを作成しました"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @category.update(category_params)
        redirect_to admin_categories_path, notice: "カテゴリを更新しました"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @category.destroy
      redirect_to admin_categories_path, notice: "カテゴリを削除しました"
    rescue StandardError => e
      redirect_to admin_categories_path, alert: e.message
    end

    private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name)
    end
  end
end
