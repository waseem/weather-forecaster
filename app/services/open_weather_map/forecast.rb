module OpenWeatherMap
  Forecast = Struct.new(
    :temperature,
    :temperature_min,
    :temperature_max,
    :description,
    :icon
  )
end
