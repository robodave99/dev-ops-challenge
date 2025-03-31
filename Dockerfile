FROM ruby:3.0-bullseye

# If you want to keep the same Bundler version as your old container:
ENV BUNDLER_VERSION=2.1.4
ENV LANG=C.UTF-8

# Install system dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      nodejs \
      yarn \
      postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install the specific Bundler version (if desired)
RUN gem install bundler:"$BUNDLER_VERSION"

# Create and use a working directory
WORKDIR /myapp

# Copy Gemfile files first, for efficient caching
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Now copy the rest of your app code
COPY . /myapp

EXPOSE 3000

# Default command to run your Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
