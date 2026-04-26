appraise 'rails_7.1' do
  gem 'rails', '~> 7.1.0'
  gem "redis-objects"
  gem 'mongoid'
  gem 'sequel'
  gem 'dynamoid'
  gem 'aws-sdk-dynamodb'
  gem 'redis-objects'
  gem 'after_commit_everywhere'
end


appraise 'rails_7.2' do
  gem 'rails', '~> 7.2.0'
  gem "redis-objects"
  gem 'mongoid'
  gem 'sequel'
  gem 'dynamoid'
  gem 'aws-sdk-dynamodb'
  gem 'redis-objects'
  gem 'after_commit_everywhere'
end

appraise 'norails' do
  gem 'sqlite3', '~> 1.3', '>= 1.3.5', platforms: :ruby
  gem 'rails', install_if: false
  gem 'sequel'
  gem 'redis-objects', '1.6.0'
  gem 'after_commit_everywhere', install_if: false
end
