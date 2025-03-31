# Use the official Ruby image
FROM ruby:2.3-slim

# Set environment variables for better performance
ENV LANG C.UTF-8
ENV BUNDLER_VERSION 2.1.4

# Fix broken Debian apt sources for legacy images
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
sed -i '/security.debian.org/d' /etc/apt/sources.list && \
apt-get update -qq && \
apt-get install -y --no-install-recommends \
nodejs \
postgresql-client \
yarn \
build-essential \
libpq-dev && \
rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /myapp

# Install Bundler
RUN gem install bundler -v "$BUNDLER_VERSION"

# Copy the Gemfile and Gemfile.lock to install dependencies
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install

# Copy the entire app to the working directory
COPY . /myapp

# Expose port 80 for the app
EXPOSE 80

# Run the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]