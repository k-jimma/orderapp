require 'rails_helper'

RSpec.describe "Table::Items", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/table/items/index"
      expect(response).to have_http_status(:success)
    end
  end
end
