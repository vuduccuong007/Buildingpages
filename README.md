# Building Pages

A standard Rails application for the Building Pages assessment.

## Stack

- Ruby 3.4.10
- Rails 8.1.3
- PostgreSQL 16
- ERB and Propshaft with `application.css`
- Importmap, Turbo, and Stimulus
- Action Mailer and Active Storage

## Run with Docker

No host Ruby or PostgreSQL installation is required:

```sh
docker compose build
docker compose run --rm web bin/rails db:prepare
docker compose run --rm web bin/rails runner "puts Rails.version"
docker compose up
```

The application is available at <http://localhost:3000>.

Docker Compose uses development-safe defaults so these commands work from a
clean checkout. To override them, copy `.env.example` to `.env` and populate
only the values needed for the local environment.

PostgreSQL data and Active Storage uploads are persisted in the
`postgres_data` and `active_storage` named volumes.

Successful apartment inquiries are delivered to Letter Opener in development.
After submitting an inquiry, open <http://localhost:3000/letter_opener> to view
the generated HTML and plain-text email. Letter Opener stores messages for
local viewing and does not launch a browser from the Docker container.

Production deployments should generally deliver inquiry emails through a
background job rather than blocking the request. Queue infrastructure is not
included in this local demonstration.

## Tests and code quality

Run the standard checks locally from an environment with the bundle installed:

```sh
bundle exec rspec
bin/rubocop
bin/brakeman --no-pager
```

With Docker Compose, use:

```sh
docker compose run --rm -e RAILS_ENV=test web bin/rails db:prepare
docker compose run --rm web bundle exec rspec
docker compose run --rm web bin/rubocop
docker compose run --rm web bin/brakeman --no-pager
```
