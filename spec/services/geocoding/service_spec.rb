require 'rails_helper'

RSpec.describe Geocoding::Service, type: :service do
  let(:address) { "10500 N De Anza Blvd" } # Apple Inc

  before do
    Geocoder.configure(lookup: :test)
  end

  after do
    Geocoder::Lookup::Test.reset
  end


  context "successful response" do
    before do
      Geocoder::Lookup::Test.add_stub(
        address, [
          {
            "coordinates" => [37.32, -122.03],
            "address" => "10500, North De Anza Boulevard, Cupertino, California, 95014",
            "state" => "California",
            "state_code" => "CA",
            "country" => "United States",
            "country_code" => "us",
            "postal_code" => "95014"
          }
        ]
      )
    end

    it "returns required attributes" do
      geocode = described_class.call(address)

      expect(geocode.latitude).to eq(37.32)
      expect(geocode.longitude).to eq(-122.03)
      expect(geocode.country_code).to eq("us")
      expect(geocode.postal_code).to eq("95014")
    end
  end

  context "unsuccessful responses" do
    context "blank response" do
      it "raises error for user to check the address" do
        allow(Geocoder).to receive(:search).with(address).and_return([])
        expect {
          described_class.call(address)
        }.to raise_error(Geocoding::Service::EmptyResponseError, "Could not geocode address. Please enter a valid address.")
      end
    end

    context "missing latitude" do
      before do
        Geocoder::Lookup::Test.add_stub(
          address,
          [
            {
              "coordinates" => [nil, -122.03],
              "address" => "10500, North De Anza Boulevard, Cupertino, California, 95014",
              "state" => "California",
              "state_code" => "CA",
              "country" => "United States",
              "country_code" => "us",
              "postal_code" => "95014"
            }
          ]
        )
      end

      it "raises for user to notify missing latitude" do
        expect {
          described_class.call(address)
        }.to raise_error(Geocoding::Service::MissingLatitudeError, "Could not determine the latitude of address.")
      end
    end

    context "missing longitude" do
      before do
        Geocoder::Lookup::Test.add_stub(
          address,
          [
            {
              "coordinates" => [37.32, nil],
              "address" => "10500, North De Anza Boulevard, Cupertino, California, 95014",
              "state" => "California",
              "state_code" => "CA",
              "country" => "United States",
              "country_code" => "us",
              "postal_code" => "95014"
            }
          ]
        )
      end

      it "raises for user to notify missing longitude" do
        expect {
          described_class.call(address)
        }.to raise_error(Geocoding::Service::MissingLongitudeError, "Could not determine the longitude of address.")
      end
    end

    context "missing country code" do
      before do
        Geocoder::Lookup::Test.add_stub(
          address,
          [
            {
              "coordinates" => [37.32, -122.03],
              "address" => "10500, North De Anza Boulevard, Cupertino, California, 95014",
              "state" => "California",
              "state_code" => "CA",
              "country" => "United States",
              "country_code" => nil,
              "postal_code" => "95014"
            }
          ]
        )
      end

      it "raises for user to notify missing country code" do
        expect {
          described_class.call(address)
        }.to raise_error(Geocoding::Service::MissingCountryCode, "Could not determine the country code of address.")
      end
    end

    context "missing postal code code" do
      before do
        Geocoder::Lookup::Test.add_stub(
          address,
          [
            {
              "coordinates" => [37.32, -122.03],
              "address" => "10500, North De Anza Boulevard, Cupertino, California, 95014",
              "state" => "California",
              "state_code" => "CA",
              "country" => "United States",
              "country_code" => "us",
              "postal_code" => nil
            }
          ]
        )
      end

      it "raises for user to notify missing country code" do
        expect {
          described_class.call(address)
        }.to raise_error(Geocoding::Service::MissingPostalCodeError, "Could not determine the postal code of address.")
      end
    end
  end
end
