require 'rails_helper'

RSpec.describe "Staff::Calls", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/staff/calls/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/staff/calls/update"
      expect(response).to have_http_status(:success)
    end
  end
end
