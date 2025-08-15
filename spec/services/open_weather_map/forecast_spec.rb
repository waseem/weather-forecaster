require 'rails_helper'

RSpec.describe OpenWeatherMap::Forecast do
  context "#icon_url" do
    it "returns the openweather icon url" do
      forecast = OpenWeatherMap::Forecast.new(icon: "02n")
      expect(forecast.icon_url).to eq("https://openweathermap.org/img/wn/02n@2x.png")
    end

    it "is blank if icon is empty" do
      forecast = OpenWeatherMap::Forecast.new(icon: "")
      expect(forecast.icon_url).to be_blank
    end
  end
end
