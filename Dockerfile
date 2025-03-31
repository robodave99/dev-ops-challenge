FROM debian:bullseye-slim

ENV LANG C.UTF-8
ENV RUBY_VERSION 2.3.8
ENV BUNDLER_VERSION 2.1.4
ENV RBENV_ROOT /usr/local/rbenv
ENV PATH $RBENV_ROOT/shims:$RBENV_ROOT/bin:$PATH

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      git \
      curl \
      wget \
      build-essential \
      libssl-dev \
      libreadline-dev \
      zlib1g-dev \
      libsqlite3-dev \
      libpq-dev \
      nodejs \
      yarn \
      postgresql-client \
      ca-certificates \
      autoconf \
      bison \
      libyaml-dev \
      libgdbm-dev \
      libncurses5-dev \
      libffi-dev && \
    rm -rf /var/lib/apt/lists/*

# Install rbenv and ruby-build
RUN git clone https://github.com/rbenv/rbenv.git $RBENV_ROOT && \
    git clone https://github.com/rbenv/ruby-build.git $RBENV_ROOT/plugins/ruby-build && \
    $RBENV_ROOT/plugins/ruby-build/install.sh

# Install Ruby 2.3
RUN rbenv install $RUBY_VERSION && \
    rbenv global $RUBY_VERSION

# Install Bundler
RUN gem install bundler -v "$BUNDLER_VERSION"

# Set working directory
WORKDIR /myapp

# Copy Gemfile and install dependencies
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install

# Copy full app
COPY . /myapp

EXPOSE 80

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]