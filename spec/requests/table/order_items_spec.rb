require 'rails_helper'

RSpec.describe "Table::OrderItems", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/table/order_items/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/table/order_items/create"
      expect(response).to have_http_status(:success)
    end
  end

end
