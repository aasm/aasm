ARG RVM_RUBY_VERSIONS="2.4.0 2.5.0"
ARG RVM_RUBY_DEFAULT="2.4.0"
FROM msati/docker-rvm

# After Ruby versions are installed we continue as non-root rvm user
USER ${RVM_USER}

LABEL maintainer="AASM"

ENV DEBIAN_FRONTEND noninteractive

# ~~~~ System locales ~~~~
RUN apt-get update && apt-get install -y locales && \
    dpkg-reconfigure locales && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8 && \
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
    locale-gen

# Set default locale for the environment
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV APP_HOME /application

# ~~~~ Application dependencies ~~~~
RUN apt-get update
RUN apt-get install -y libsqlite3-dev \
                       build-essential \
                       git

# ~~~~ Bundler ~~~~
RUN gem install bundler

WORKDIR $APP_HOME
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
