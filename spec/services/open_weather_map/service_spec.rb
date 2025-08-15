require 'rails_helper'

RSpec.describe OpenWeatherMap::Service, type: :service do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) { Faraday.new { |builder| builder.adapter(:test, stubs) } }
  let(:endpoint) { "data/2.5/weather" }
  let(:latitude) { 37.323 }
  let(:longitude) { -122.0322 }
  let(:country_code) { "us" }
  let(:postal_code) { "95014" }
  let(:response_body) do
  end

  before do
    allow(Faraday).to receive(:new).and_return(connection)
  end

  context "when Faraday raises an error" do
    before do
      stubs.get(endpoint) { raise Faraday::ConnectionFailed.new("API unreachable") }
    end

    it "logs the error and exits gracefully" do
      expect(Rails.logger).to receive(:error).with(/API unreachable/)
      expect { described_class.new.call(latitude, longitude, country_code, postal_code) }.to raise_error(
        OpenWeatherMap::Service::UnavailableError,
        "Something went wrong while requesting forecast. Please try again later."
      )
    end
  end

  context "when response is empty" do
    it "raises empty response error" do
      stubs.get(endpoint) { |env| [200, {}, {}]}
      expect { described_class.new.call(latitude, longitude, country_code, postal_code) }.to raise_error(
        OpenWeatherMap::Service::EmptyResponseError,
        "OpenWeather: empty response. Try again later."
      )
    end
  end

  context "when main section is empty" do
    it "raises empty main section error" do
      stubs.get(endpoint) { |env| [200, {}, { "main" => nil }]}
      expect { described_class.new.call(latitude, longitude, country_code, postal_code) }.to raise_error(
        OpenWeatherMap::Service::MainSectionEmptyError,
        "OpenWeather: empty main section. Try again later."
      )
    end
  end

  context "when temperature is missing" do
    it "raises temperature missing error" do
      stubs.get(endpoint) { |env| [200, {}, { "main" => { "temp" => nil } }]}
      expect { described_class.new.call(latitude, longitude, country_code, postal_code) }.to raise_error(
        OpenWeatherMap::Service::TemperatureMissingError,
        "OpenWeather: temperature is missing. Try again later."
      )
    end
  end

  context "when min temperature is missing" do
    it "raises minimum temperature missing error" do
      stubs.get(endpoint) do |env|
        [
          200,
          {},
          {
            "main" => {
              "temp" => 17.25,
              "temp_min" => nil
            }
          }
        ]
      end
      expect { described_class.new.call(latitude, longitude, country_code, postal_code) }.to raise_error(
        OpenWeatherMap::Service::TemperatureMinMissingError,
        "OpenWeather: minimum temperature is missing. Try again later."
      )
    end
  end

  context "when max temperature is missing" do
    it "raises maximum temperature missing error" do
      stubs.get(endpoint) do |env|
        [
          200,
          {},
          {
            "main" => {
              "temp" => 17.25,
              "temp_min" => 14.89,
              "temp_max" => nil
            }
          }
        ]
      end
      expect { described_class.new.call(latitude, longitude, country_code, postal_code) }.to raise_error(
        OpenWeatherMap::Service::TemperatureMaxMissingError,
        "OpenWeather: maximum temperature is missing. Try again later."
      )
    end
  end

  context "when weather section is missing or empty" do
    it "raises weather section empty error for missing" do
      stubs.get(endpoint) do |env|
        [
          200,
          {},
          {
            "main" => {
              "temp" => 17.25,
              "temp_min" => 14.89,
              "temp_max" => 18.75
            },
            "weather" => nil
          }
        ]
      end
      expect { described_class.new.call(latitude, longitude, country_code, postal_code) }.to raise_error(
        OpenWeatherMap::Service::WeatherSectionEmptyError,
        "OpenWeather: empty weather section. Try again later."
      )
    end

    it "raises weather section empty error for empty" do
      stubs.get(endpoint) do |env|
        [
          200,
          {},
          {
            "main" => {
              "temp" => 17.25,
              "temp_min" => 14.89,
              "temp_max" => 18.75
            },
            "weather" => [],
          }
        ]
      end
      expect { described_class.new.call(latitude, longitude, country_code, postal_code) }.to raise_error(
        OpenWeatherMap::Service::WeatherSectionEmptyError,
        "OpenWeather: empty weather section. Try again later."
      )
    end
  end

  context "when weather section has missing description" do
    it "raises missign description error" do
      stubs.get(endpoint) do |env|
        [
          200,
          {},
          {
            "main" => {
              "temp" => 17.25,
              "temp_min" => 14.89,
              "temp_max" => 18.75
            },
            "weather" => [
              {
                "description" => nil
              }
            ],
          }
        ]
      end
      expect { described_class.new.call(latitude, longitude, country_code, postal_code) }.to raise_error(
        OpenWeatherMap::Service::WeatherDescriptionMissingError,
        "OpenWeather: missing weather description. Try again later."
      )
    end
  end

  context "when weather section has missing icon" do
    it "raises missign icon error" do
      stubs.get(endpoint) do |env|
        [
          200,
          {},
          {
            "main" => {
              "temp" => 17.25,
              "temp_min" => 14.89,
              "temp_max" => 18.75
            },
            "weather" => [
              {
                "description" => "few clouds",
                "icon" => nil
              }
            ],
          }
        ]
      end
      expect { described_class.new.call(latitude, longitude, country_code, postal_code) }.to raise_error(
        OpenWeatherMap::Service::WeatherIconMissingError,
        "OpenWeather: missing weather icon. Try again later."
      )
    end
  end

  context "successful response" do
    it "returns a forecast object" do
      stubs.get(endpoint) do |env|
        [
          200,
          {},
          {
            "main" => {
              "temp" => 17.25,
              "temp_min" => 14.89,
              "temp_max" => 18.75,
            },
            "weather" => [{
              "description" => "few clouds",
              "icon" => "02n"
            }],
          }
        ]
      end
      forecast = described_class.new.call(latitude, longitude, country_code, postal_code)

      expect(forecast.temperature).to eq(17.25)
      expect(forecast.temperature_min).to eq(14.89)
      expect(forecast.temperature_max).to eq(18.75)
      expect(forecast.description).to eq("few clouds")
      expect(forecast.icon).to eq("02n")
    end
  end
end
