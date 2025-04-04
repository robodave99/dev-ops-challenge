FROM ruby:2.3.8

# Replace default Stretch sources with the archived repositories
RUN rm /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian/ stretch main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security/ stretch/updates main contrib non-free" >> /etc/apt/sources.list && \
    # Stop APT from complaining about expired Release files
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

# Now install dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs

WORKDIR /app

# Copy Gemfiles first for caching
COPY Gemfile Gemfile.lock /app/
RUN bundle install

# Copy the rest of the code
COPY . /app

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
