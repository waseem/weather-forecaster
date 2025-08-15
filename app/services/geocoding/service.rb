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
        raise EmptyResponseError.new("Geocoding: failed, enter valid address") if response.blank?

        geocoded = response.first
        validate_response!(geocoded)
        geocoded
      end

      private

      def validate_response!(geocoded)
        raise MissingLatitudeError.new("Geocoding: missing latitude") if geocoded.latitude.blank?
        raise MissingLongitudeError.new("Geocoding: missing longitude") if geocoded.longitude.blank?
        raise MissingCountryCode.new("Geocoding: missing country code") if geocoded.country_code.blank?
        raise MissingPostalCodeError.new("Geocoding: missing postal code") if geocoded.postal_code.blank?
        raise MissingAddressError.new("Geocoding: missing address") if geocoded.address.blank?
      end
    end
  end
end
