module Customer
  class ItemsController < Customer::BaseController
    include TableAccessGuard

    def index
      @root_categories = Category.where(parent_id: nil).includes(children: :items).order(:sort_order, :name)
      @middle_categories = Category.where(parent_id: @root_categories.map(&:id))
                                  .includes(:items, children: :items)
                                  .order(:sort_order, :name)
    end
  end
end
