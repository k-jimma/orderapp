require 'rails_helper'

RSpec.describe "Table::Orders", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/table/orders/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/table/orders/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /complete" do
    it "returns http success" do
      get "/table/orders/complete"
      expect(response).to have_http_status(:success)
    end
  end
end
