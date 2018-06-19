# encoding: utf-8
begin
  require 'active_record'

  puts "active_record #{ActiveRecord::VERSION::STRING} gem found, running ActiveRecord specs \e[32m#{'✔'}\e[0m"
rescue LoadError
  puts "active_record gem not found, not running ActiveRecord specs \e[31m#{'✖'}\e[0m"
end
