module OpenWeatherMap
  class Service
    # See https://openweathermap.org/current for details and response structure
    API_URL = "https://api.openweathermap.org".freeze

    class UnavailableError < StandardError; end
    class EmptyResponseError < StandardError; end
    class MainSectionEmptyError < StandardError; end
    class TemperatureMissingError < StandardError; end
    class TemperatureMinMissingError < StandardError; end
    class TemperatureMaxMissingError < StandardError; end
    class WeatherSectionEmptyError < StandardError; end
    class WeatherDescriptionMissingError < StandardError; end
    class WeatherIconMissingError < StandardError; end

    attr_reader :connection

    def initialize
      @connection = Faraday.new(
        url: API_URL,
        params: { appid: Rails.application.credentials[:openweather_api_key] }
      ) do |builder|
        builder.response :json # Encode request body as json and set the Content-Type header
        builder.request :json # Decode response body to json
      end
    end

    def call(latitude, longitude, country_code, postal_code)
      from_cache = true
      response = Rails.cache.fetch(cache_key(country_code, postal_code), expires_in: 30.minutes) do
        from_cache = false
        fetch_forecast!(latitude, longitude)
      end

      prepare_forecast(response, from_cache)
    end

    private

    def cache_key(country_code, postal_code)
      "#{country_code}-#{postal_code}"
    end

    def fetch_forecast!(latitude, longitude)
      begin
        response = connection.get("data/2.5/weather", {
          lat: latitude,
          lon: longitude,
          units: "metric" # other options are `standard`, and `imperial`
        })
      rescue Faraday::Error => e
        logger.error("An error occurred while requesting forecast: #{e.message}")
        raise UnavailableError.new("Something went wrong while requesting forecast. Please try again later.")
      end

      json_response = response.body
      validate_response!(json_response)
      {
        temperature: json_response.dig("main", "temp"),
        temperature_min: json_response.dig("main", "temp_min"),
        temperature_max: json_response.dig("main", "temp_max"),
        description: json_response.dig("weather").first.dig("description"),
        icon: json_response.dig("weather").first.dig("icon")
      }
    end

    def validate_response!(json_response)
      raise EmptyResponseError.new("OpenWeather: empty response. Try again later.") if json_response.blank?
      raise MainSectionEmptyError.new("OpenWeather: empty main section. Try again later.") if json_response["main"].blank?
      raise TemperatureMissingError.new(
        "OpenWeather: temperature is missing. Try again later."
      ) if json_response.dig("main", "temp").blank?
      raise TemperatureMinMissingError.new(
        "OpenWeather: minimum temperature is missing. Try again later."
      ) if json_response.dig("main", "temp_min").blank?
      raise TemperatureMaxMissingError.new(
        "OpenWeather: maximum temperature is missing. Try again later."
      ) if json_response.dig("main", "temp_max").blank?
      raise WeatherSectionEmptyError.new(
        "OpenWeather: empty weather section. Try again later."
      ) if json_response["weather"].blank?

      weather = json_response["weather"].first
      raise WeatherDescriptionMissingError.new(
        "OpenWeather: missing weather description. Try again later."
      ) if weather["description"].blank?
      raise WeatherIconMissingError.new(
        "OpenWeather: missing weather icon. Try again later."
      ) if weather["icon"].blank?
    end

    def prepare_forecast(response, from_cache)
      Forecast.new(
        temperature: response[:temperature],
        temperature_min: response[:temperature_min],
        temperature_max: response[:temperature_max],
        description: response[:description],
        icon: response[:icon],
        from_cache: from_cache
      )
    end

    def logger
      Rails.logger
    end
  end
end
