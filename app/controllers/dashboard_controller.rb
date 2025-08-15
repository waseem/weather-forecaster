class DashboardController < ApplicationController
  DEFAULT_ADDRESS = "10500 N De Anza Blvd" # Apple Inc

  def index
    @address = params[:address].presence || DEFAULT_ADDRESS
    begin
      @geocoded = Geocoding::Service.call(@address)
      @forecast = OpenWeatherMap::Service.new.call(@geocoded.latitude, @geocoded.longitude)
    rescue => e
      flash.alert = e.message
    end
  end
end
