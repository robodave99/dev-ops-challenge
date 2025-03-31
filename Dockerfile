# Use the official Ruby image
FROM ruby:2.3

# Set environment variables for better performance
ENV LANG C.UTF-8
ENV BUNDLER_VERSION 2.1.4

# Install dependencies for Rails app
RUN apt-get update -qq 
RUN apt-get install -y nodejs 
RUN apt-get -y postgresql-client 
RUN apt-get -y yarn 
RUN apt-get -y build-essential 
RUN apt-get -y libpq-dev

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
