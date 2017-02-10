# encoding: utf-8
begin
  require 'redis-objects'
  puts "redis-objects gem found, running Redis specs \e[32m#{'✔'}\e[0m"
rescue LoadError
  puts "redis-objects gem not found, not running Redis specs \e[31m#{'✖'}\e[0m"
end
