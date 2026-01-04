module Table
  class ItemsController < BaseController
    include TableAccessGuard

    def index
      @categories = Category.includes(:items).order(:id)
    end
  end
end
