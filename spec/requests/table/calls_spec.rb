require 'rails_helper'

RSpec.describe "Table::Calls", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/table/calls/create"
      expect(response).to have_http_status(:success)
    end
  end
end
