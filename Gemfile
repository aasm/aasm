source "https://rubygems.org"

gem "sqlite3",                          :platforms => :ruby
gem 'rubysl',                           :platforms => :rbx
gem "jruby-openssl",                    :platforms => :jruby
gem "activerecord-jdbcsqlite3-adapter", :platforms => :jruby
gem "mime-types", "~> 2" if Gem::Version.create(RUBY_VERSION.dup) <= Gem::Version.create('1.9.3')
gem "rails", "~>4.2"
gem 'mongoid', '~>4.0' if Gem::Version.create(RUBY_VERSION.dup) >= Gem::Version.create('1.9.3')
gem 'sequel'

# testing dynamoid
# gem 'dynamoid', '~> 1'
# gem 'aws-sdk', '~>2'

# Since mongoid V4 requires incompatible bson V2, cannot have mongoid (V4 or greater)
# and mongo_mapper ( or mongo ) in the same application
# gem 'mongo_mapper', '~> 0.13'
# gem 'bson_ext',                          :platforms => :ruby

# uncomment if you want to run specs for Redis persistence
# gem "redis-objects"

gemspec
