require 'rails_helper'

RSpec.describe "Admin::Tables", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/tables/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/admin/tables/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /generate_pin" do
    it "returns http success" do
      get "/admin/tables/generate_pin"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /generate_pin_bulk" do
    it "returns http success" do
      get "/admin/tables/generate_pin_bulk"
      expect(response).to have_http_status(:success)
    end
  end

end
