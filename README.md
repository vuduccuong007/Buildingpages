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

## Tests

```sh
docker compose run --rm web bin/rails test
```
