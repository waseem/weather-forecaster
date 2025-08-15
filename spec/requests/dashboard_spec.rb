require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  describe "GET /index" do
    it "shows the page with an address input" do
      get root_path

      expect(response).to have_http_status(:ok)
    end
  end
end
