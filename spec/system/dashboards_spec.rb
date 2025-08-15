require 'rails_helper'

RSpec.describe "Dashboards", type: :system do
  let(:geocoded) {
    OpenStruct.new(
      latitude: 37.32,
      longitude: -122.03,
      address:"10500 N De Anza Blvd",
      country_code: "us",
      postal_code: "95014"
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
      description: "clear sky"
    )
  end

  before do
    driven_by(:rack_test)
    allow(OpenWeatherMap::Service).to receive(:new) { forecast_service }
  end

  context "successful visit" do
    before do
      allow(Geocoding::Service).to receive(:call) { geocoded }
      allow(forecast_service).to receive(:call)
        .with(
          geocoded.latitude,
          geocoded.longitude,
          geocoded.country_code,
          geocoded.postal_code
        ) { forecast }
    end

    it "shows forecast for an address" do
      visit root_path
      expect(page).to have_text("Your Weather Forecast")
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
          receive(:call)
            .with(
              geocoded.latitude,
              geocoded.longitude,
              geocoded.country_code,
              geocoded.postal_code
            ) do
            raise OpenWeatherMap::Service::UnavailableError.new("An error occurred while requesting forecast")
          end
        )

        visit root_path
        expect(page).to have_text("An error occurred while requesting forecast")
      end
    end
  end
end
