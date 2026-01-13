require 'rails_helper'

RSpec.describe "Staff::Orders", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/staff/orders/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/staff/orders/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /start_billing" do
    it "returns http success" do
      get "/staff/orders/start_billing"
      expect(response).to have_http_status(:success)
    end
  end

end
