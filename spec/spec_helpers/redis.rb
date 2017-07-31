# encoding: utf-8
begin
  require 'redis-objects'
  puts "redis-objects gem found, running Redis specs \e[32m#{'✔'}\e[0m"

  Redis.current = Redis.new(host: '127.0.0.1', port: 6379)

  RSpec.configure do |c|
    c.before(:each) do
      Redis.current.keys('redis_*').each { |k| Redis.current.del k }
    end
  end
rescue LoadError
  puts "redis-objects gem not found, not running Redis specs \e[31m#{'✖'}\e[0m"
end
