module Orders
  class AddItem
    def initialize(order:, item_id:, quantity:, note:)
      @order = order
      @item_id = item_id
      @quantity = quantity.to_i
      @note = note
    end

    def call!
      @order.ensure_open!

      item = Item.find(@item_id)
      raise ArgumentError, "売切れのため注文できません" unless item.is_available?

      OrderItem.create!(
        order: @order,
        item: item,
        quantity: (@quantity <= 0 ? 1 : @quantity),
        note: @note,
        status: :new
      )
    end
  end
end
