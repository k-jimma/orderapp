require 'rails_helper'

RSpec.describe "Customer::TableStatuses", type: :request do
  describe "GET /activate" do
    it "returns http success" do
      get "/customer/table_statuses/activate"
      expect(response).to have_http_status(:success)
    end
  end
end
