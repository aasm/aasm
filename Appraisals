appraise 'rails_3.2' do
  gem 'rails', '~> 3.2.22'
  gem 'mongoid', '~> 3.1'
  gem 'sequel'
  gem 'bson_ext', platforms: :ruby
  gem 'test-unit', '~> 3.0'
  gem 'minitest'
  gem 'activerecord-jdbcsqlite3-adapter', '1.3.24', platforms: :jruby
end

appraise 'rails_4.2' do
  gem 'nokogiri', '1.6.8.1', platforms: %i[ruby_19]
  gem 'mime-types', '~> 2', platforms: %i[ruby_19 jruby]
  gem 'rails', '4.2.5'
  gem 'mongoid', '~> 4.0'
  gem 'sequel'
  gem 'dynamoid', '~> 1', platforms: :ruby
  gem 'aws-sdk', '~> 2', platforms: :ruby
  gem 'redis-objects'
  gem 'activerecord-jdbcsqlite3-adapter', '1.3.24', platforms: :jruby
end

appraise 'rails_4.2_nobrainer' do
  gem 'rails', '4.2.5'
  gem 'nobrainer', '~> 0.33.0'
end

appraise 'rails_4.2_mongoid_5' do
  gem 'mime-types', '~> 2', platforms: %i[ruby_19 jruby]
  gem 'rails', '4.2.5'
  gem 'mongoid', '~> 5.0'
  gem 'activerecord-jdbcsqlite3-adapter', '1.3.24', platforms: :jruby
end

appraise 'rails_5.0' do
  gem 'rails', '5.0.0'
  gem 'mongoid', '~> 6.0'
  gem 'sequel'
  gem 'dynamoid', '~> 1.3', platforms: :ruby
  gem 'aws-sdk', '~> 2', platforms: :ruby
  gem 'redis-objects'
end

appraise 'rails_5.0_nobrainer' do
  gem 'rails', '5.0.0'
  gem 'nobrainer', '~> 0.33.0'
end

appraise 'rails_5.1' do
  gem 'rails', '5.1'
  gem 'mongoid', '~>6.0'
  gem 'sequel'
  gem 'dynamoid', '~> 1.3', platforms: :ruby
  gem 'aws-sdk', '~>2', platforms: :ruby
  gem 'redis-objects'
end

appraise 'rails_5.2' do
  gem 'rails', '5.2'
  gem 'mongoid', '~>6.0'
  gem 'sequel'
  gem 'dynamoid', '~>2.2', platforms: :ruby
  gem 'aws-sdk', '~>2', platforms: :ruby
  gem 'redis-objects'
end

appraise 'norails' do
  gem 'rails', install_if: false
  gem 'sequel'
  gem 'redis-objects'
end
