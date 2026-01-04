module Table
  class BaseController < ApplicationController
    include TableTokenAuth

    layout "table"

    private

    def find_or_create_open_order!
      current_table.find_or_create_open_order!
    end
  end
end
