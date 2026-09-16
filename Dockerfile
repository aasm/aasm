FROM ruby:3.3-slim

LABEL maintainer="AASM"

ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    APP_HOME=/application

# ~~~~ System dependencies ~~~~
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      git \
      libsqlite3-dev \
      tzdata \
    && rm -rf /var/lib/apt/lists/*

# ~~~~ Bundler ~~~~
RUN gem install bundler -v '~> 2.5'

WORKDIR $APP_HOME

# ~~~~ Pre-install base dependencies for layer caching ~~~~
RUN mkdir -p $APP_HOME/lib/aasm/
COPY Gemfile* $APP_HOME/
COPY *.gemspec $APP_HOME/
COPY lib/aasm/version.rb $APP_HOME/lib/aasm/

ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
    BUNDLE_JOBS=8 \
    BUNDLE_PATH=/bundle

RUN bundle install

# ~~~~ Import application ~~~~
COPY . $APP_HOME
