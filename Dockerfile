FROM debian:bullseye-slim

ENV LANG C.UTF-8
ENV RUBY_VERSION 2.3.8
ENV BUNDLER_VERSION 2.1.4

ENV RBENV_ROOT /usr/local/rbenv
ENV PATH       $RBENV_ROOT/shims:$RBENV_ROOT/bin:$PATH

# (Install your build dependencies)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      git curl wget build-essential libssl-dev libreadline-dev zlib1g-dev \
      libsqlite3-dev libpq-dev nodejs yarn postgresql-client ca-certificates \
      autoconf bison libyaml-dev libgdbm-dev libncurses5-dev libffi-dev && \
    rm -rf /var/lib/apt/lists/*

# Install rbenv & ruby-build
RUN git clone https://github.com/rbenv/rbenv.git $RBENV_ROOT && \
    git clone https://github.com/rbenv/ruby-build.git $RBENV_ROOT/plugins/ruby-build && \
    $RBENV_ROOT/plugins/ruby-build/install.sh

# Tell ruby-build to use Debian’s OpenSSL
# so that we do NOT end up mixing OpenSSL 1.0 & 1.1
ENV CONFIGURE_OPTS="--with-openssl-dir=/usr"

# Now install Ruby 2.3.8 (which will link against system OpenSSL 1.1)
RUN rbenv install $RUBY_VERSION && \
    rbenv global $RUBY_VERSION

# Install Bundler
RUN gem install bundler -v "$BUNDLER_VERSION"

WORKDIR /myapp
COPY Gemfile      /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock

RUN bundle install

COPY . /myapp
EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
