module Geocoding
  class Service
    class EmptyResponseError < StandardError; end
    class MissingLatitudeError < StandardError; end
    class MissingLongitudeError < StandardError; end
    class MissingCountryCode < StandardError; end
    class MissingPostalCodeError < StandardError; end
    class MissingAddressError < StandardError; end

    class << self
      def call(address)
        response = Geocoder.search(address)
        raise EmptyResponseError.new("Could not geocode address. Please enter a valid address.") if response.blank?

        geocoded = response.first
        validate_response!(geocoded)
        geocoded
      end

      private

      def validate_response!(geocoded)
        raise MissingLatitudeError.new("Could not determine the latitude of address.") if geocoded.latitude.blank?
        raise MissingLongitudeError.new("Could not determine the longitude of address.") if geocoded.longitude.blank?
        raise MissingCountryCode.new("Could not determine the country code of address.") if geocoded.country_code.blank?
        raise MissingPostalCodeError.new("Could not determine the postal code of address.") if geocoded.postal_code.blank?
        raise MissingAddressError.new("Could not determine the address.") if geocoded.address.blank?
      end
    end
  end
end
