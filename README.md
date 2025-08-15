# README

## Tech Stack

- Ruby `3.4.4`
- Rails `8.0.2`
- Postgres

## Application setup

- Ensure you have Ruby `3.4.4` installed and selected. `.tool-versions` (works with `asdf`) to lock the versions.
- `bundle install`
- `cp ../master.key config/`
- `bundle exec rails db:create`
- `bundle exec rails db:migrate`
- `bundle exec rails s`
- Visit `http://localhost:3000`
- `bundle exec rspec spec` # Run all specs
- `bundle exec rubocop` # Run rubocop linting rules
