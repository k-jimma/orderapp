require 'rails_helper'

RSpec.describe "Admin::Items", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/items/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/admin/items/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/admin/items/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/admin/items/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/admin/items/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/admin/items/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
