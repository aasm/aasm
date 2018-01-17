# encoding: utf-8

begin
  require 'redis-objects'
  require 'redis/objects/version'
  puts "redis-objects #{Redis::Objects::VERSION} gem found, running Redis specs \e[32m#{'✔'}\e[0m"

  Redis.current = Redis.new(host: (ENV['REDIS_HOST'] || '127.0.0.1'),
                            port: (ENV['REDIS_PORT'] || 6379))

  RSpec.configure do |c|
    c.before(:each) do
      Redis.current.keys('redis_*').each { |k| Redis.current.del k }
    end
  end
rescue LoadError
  puts "redis-objects gem not found, not running Redis specs \e[31m#{'✖'}\e[0m"
end
