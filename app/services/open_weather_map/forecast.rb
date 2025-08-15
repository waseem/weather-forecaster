module OpenWeatherMap
  Forecast = Struct.new(
    :temperature,
    :temperature_min,
    :temperature_max,
    :description,
    :icon
  ) do |klass|
    def icon_url
      return "" if icon.blank?
      "https://openweathermap.org/img/wn/#{icon}@2x.png"
    end
  end
end
