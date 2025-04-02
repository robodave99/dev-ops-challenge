FROM debian:bullseye

# Install all necessary packages
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
  postgresql-client

ENV LANG=C.UTF-8
ENV RBENV_ROOT=/usr/local/rbenv
ENV RUBY_VERSION=2.3.8
ENV PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"

# Install rbenv
RUN git clone https://github.com/rbenv/rbenv.git "$RBENV_ROOT" && \
    git clone https://github.com/rbenv/ruby-build.git "$RBENV_ROOT/plugins/ruby-build" && \
    cd "$RBENV_ROOT" && src/configure && make -C src

# Install Ruby 2.3.8 and Bundler
RUN rbenv install "$RUBY_VERSION" && \
    rbenv global "$RUBY_VERSION" && \
    gem install bundler -v 2.1.4

WORKDIR /myapp

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . /myapp

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
