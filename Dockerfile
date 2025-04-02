FROM debian:bullseye

# 1) Install system packages needed to build Ruby 2.3
#    * ca-certificates is important so SSL downloads work
#    * curl or wget is required by ruby-build to fetch sources
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    autoconf \
    bison \
    libssl-dev \
    libyaml-dev \
    libreadline-dev \
    libncurses5-dev \
    libffi-dev \
    libgdbm-dev \
    libpq-dev \
    nodejs \
    yarn \
    postgresql-client \
    curl \
    ca-certificates

ENV LANG=C.UTF-8
ENV RBENV_ROOT=/usr/local/rbenv
ENV RUBY_VERSION=2.3.8
ENV PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"

# 2) Install rbenv and ruby-build
RUN git clone https://github.com/rbenv/rbenv.git "$RBENV_ROOT" && \
    git clone https://github.com/rbenv/ruby-build.git "$RBENV_ROOT/plugins/ruby-build" && \
    cd "$RBENV_ROOT" && src/configure && make -C src

# 3) Override the OpenSSL URL for older Ruby. 
#    Older versions expect OpenSSL 1.0.2u at a location that no longer exists 
#    in the main /source directory. The "old/1.0.2/" path is needed.
ENV RUBY_BUILD_OPENSSL_URL="https://www.openssl.org/source/old/1.0.2/openssl-1.0.2u.tar.gz"

# 4) Install Ruby 2.3.8 and Bundler
RUN rbenv install "$RUBY_VERSION" && \
    rbenv global "$RUBY_VERSION" && \
    gem install bundler -v 2.1.4

WORKDIR /myapp

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . /myapp

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
