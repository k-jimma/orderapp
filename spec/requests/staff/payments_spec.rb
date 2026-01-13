require 'rails_helper'

RSpec.describe "Staff::Payments", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/staff/payments/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/staff/payments/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/staff/payments/show"
      expect(response).to have_http_status(:success)
    end
  end

end
