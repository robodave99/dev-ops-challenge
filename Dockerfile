# Use the official Ruby image
FROM ruby:2.3

# Install dependencies for Rails app
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

# Set the working directory in the container
WORKDIR /myapp

# Install Bundler
RUN gem install bundler

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
