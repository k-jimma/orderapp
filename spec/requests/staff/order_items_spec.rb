require 'rails_helper'

RSpec.describe "Staff::OrderItems", type: :request do
  describe "GET /to_cooking" do
    it "returns http success" do
      get "/staff/order_items/to_cooking"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /to_ready" do
    it "returns http success" do
      get "/staff/order_items/to_ready"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /to_served" do
    it "returns http success" do
      get "/staff/order_items/to_served"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /cancel" do
    it "returns http success" do
      get "/staff/order_items/cancel"
      expect(response).to have_http_status(:success)
    end
  end

end
