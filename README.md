# README

## Tech Stack

- Ruby `3.4.4`
- Rails `8.0.2`
- Postgres

## Application setup

- Ensure you have Ruby `3.4.4` installed and selected. `.tool-versions` (works with `asdf`) to lock the versions.
- `bundle install`
- `yarn install`
- `cp ../master.key config/` # Provided separately
- `bundle exec rails db:create`
- `bundle exec rails db:migrate`
- `bundle exec rails s`
- `bundle exec rails tailwindcss:watch`
- Visit `http://localhost:3000`
- `bundle exec rspec spec` # Run all specs
- `bundle exec rubocop` # Run rubocop linting rules

## Overview of operations
- Getting weather forecast for the given address
  - I am choosing to convert the provided address to a latitude and longitude by using the [`geocoder`](https://github.com/alexreisner/geocoder) rubygem.
  - I am using the (default) [Nominatim](https://github.com/alexreisner/geocoder/blob/master/README_API_GUIDE.md#nominatim-nominatim) API for geocoding the address.
  - Once the latitude and longitude is acquired, I am passing it to the OpenWeatherMap REST API to fetch the forecast.
  - The retrieved forecast is then displayed to the user.

## Technical overview

- `DashboardController` is responsible for:
  - Displaying the weather forecast for the entered address.
  - Accepting the address as an input.
- `Geocoding::Service` is responsible for:
  - Retrieving the latitude, longitude, country code, and postal code of the provided address after geocoding. (1 request/second; see limitation below)
- `OpenWeatherMap::Service` is responsible for:
  - Calling the open weather map API to retrieve the current forecast.
- `OpenWeatherMap::Forecast` is a wrapper object to easily store and pass around the forecast.

## Assumptions

## Limitations
- The default geocoder API Nominatim has a limit of 1 request per second for geocoding. It can easily be increased by utilizing other services like ArcGis, Google, or Bing.
