require 'rails_helper'

RSpec.describe "Dashboards", type: :system do
  let(:geocoded) { OpenStruct.new(latitude: 37.32, longitude: -122.03) }
  let(:forecast_service) { double("Forecast Service") }
  let(:forecast) { instance_double("Forecast", temperature: 17.25) }

  before do
    driven_by(:rack_test)
    allow(OpenWeatherMap::Service).to receive(:new) { forecast_service }
  end

  context "successful visit" do
    before do
      allow(Geocoding::Service).to receive(:call) { geocoded }
      allow(forecast_service).to receive(:call).with(geocoded.latitude, geocoded.longitude) { forecast }
    end

    it "shows forecast for an address" do
      visit root_path
      expect(page).to have_text("Your weather forecast")
    end

    it "shows an address input field" do
      visit root_path
      expect(page).to have_field("address")
    end
  end

  context "unsuccessful visit" do
    context "error geocoding" do
      it "shows error in flash message" do
        allow(Geocoding::Service).to receive(:call) { raise Geocoding::Service::MissingAddressError.new("Missing address after geocoding.") }

        visit root_path
        expect(page).to have_text("Missing address after geocoding.")
      end
    end

    context "error forecasting" do
      it "shows error in flash message" do
        allow(Geocoding::Service).to receive(:call) { geocoded }
        allow(forecast_service).to(
          receive(:call).with(geocoded.latitude, geocoded.longitude) do
            raise OpenWeatherMap::Service::UnavailableError.new("An error occurred while requesting forecast")
          end
        )

        visit root_path
        expect(page).to have_text("An error occurred while requesting forecast")
      end
    end
  end
end
