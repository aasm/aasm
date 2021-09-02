appraise 'rails_4.2' do
  gem 'nokogiri', '1.6.8.1', platforms: %i[ruby_19]
  gem 'mime-types', '~> 2', platforms: %i[ruby_19 jruby]
  gem 'sqlite3', '~> 1.3.5', platforms: :ruby
  gem 'rails', '~> 4.2.11'
  gem 'mongoid', '~> 4.0'
  gem 'sequel'
  gem 'dynamoid', '~> 1', platforms: :ruby
  gem 'aws-sdk', '~> 2', platforms: :ruby
  gem 'redis-objects'
  gem 'activerecord-jdbcsqlite3-adapter', '1.3.24', platforms: :jruby
  gem "after_commit_everywhere", "~> 1.0"
end

appraise 'rails_4.2_mongoid_5' do
  gem 'sqlite3', '~> 1.3.5', platforms: :ruby
  gem 'mime-types', '~> 2', platforms: %i[ruby_19 jruby]
  gem 'rails', '~> 4.2.11'
  gem 'mongoid', '~> 5.0'
  gem 'activerecord-jdbcsqlite3-adapter', '1.3.24', platforms: :jruby
  gem "after_commit_everywhere", "~> 1.0"
end

appraise 'rails_5.2' do
  gem 'sqlite3', '~> 1.3.5', platforms: :ruby
  gem 'rails', '~> 5.2.4'
  gem 'mongoid', '~>6.0'
  gem 'sequel'
  gem 'dynamoid', '~>2.2', platforms: :ruby
  gem 'aws-sdk', '~>2', platforms: :ruby
  gem 'redis-objects'
  gem "after_commit_everywhere", "~> 1.0"
end

appraise 'rails_6.1' do
  gem 'rails', '~> 6.1.4'
  gem 'mongoid', '~>7.0', '>= 7.0.5'
  gem 'sequel'
  gem 'dynamoid', '~>3.3', platforms: :ruby
  gem 'aws-sdk-dynamodb', '~> 1'
  gem 'redis-objects'
  gem "after_commit_everywhere", "~> 1.0"
end

appraise 'norails' do
  gem 'sqlite3', '~> 1.3', '>= 1.3.5', platforms: :ruby
  gem 'rails', install_if: false
  gem 'sequel'
  gem 'redis-objects'
  gem "after_commit_everywhere", install_if: false
end
