require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  let(:geocoded) {
    OpenStruct.new(
      latitude: 37.32,
      longitude: -122.03,
      address: "10500 N De Anza Blvd",
      country_code: "us",
      postal_code: "95014",
    )
  }
  let(:forecast_service) { double("Forecast Service") }
  let(:forecast) do
    instance_double(
      "Forecast",
      temperature: 17.25,
      temperature_min: 14.89,
      temperature_max: 18.75,
      icon_url: "https://openweathermap.org/img/wn/10d@2x.png",
      description: "clear sky",
      from_cache: true
    )
  end

  before do
    allow(OpenWeatherMap::Service).to receive(:new) { forecast_service }
  end

  describe "GET /index" do
    it "shows the page successfully" do
      allow(Geocoding::Service).to receive(:call) { geocoded }
      allow(forecast_service).to receive(:call)
        .with(
          geocoded.latitude,
          geocoded.longitude,
          geocoded.country_code,
          geocoded.postal_code
        ) { forecast }

      get root_path

      expect(response).to have_http_status(:ok)
    end
  end
end
