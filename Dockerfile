# syntax=docker/dockerfile:1

FROM ruby:3.4.10-slim

ENV BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_JOBS="4" \
    BUNDLE_RETRY="3"

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
      libvips \
      libyaml-dev \
      pkg-config \
      postgresql-client && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
RUN chmod +x bin/docker-entrypoint

ENTRYPOINT ["bin/docker-entrypoint"]

EXPOSE 3000

CMD ["bin/rails", "server", "--binding", "0.0.0.0", "--port", "3000"]
