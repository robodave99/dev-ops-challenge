FROM ruby:2.3-slim

ENV LANG C.UTF-8
ENV BUNDLER_VERSION 2.1.4

# Fix broken sources for Debian Jessie
RUN echo "deb http://archive.debian.org/debian jessie main" > /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        nodejs \
        postgresql-client \
        yarn \
        build-essential \
        libpq-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /myapp

RUN gem install bundler -v "$BUNDLER_VERSION"

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install

COPY . /myapp

EXPOSE 80

CMD ["rails", "server", "-b", "0.0.0.0"]