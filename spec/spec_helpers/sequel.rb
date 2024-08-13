# encoding: utf-8
begin
  require 'sequel'
  puts "sequel #{Sequel::VERSION} gem found, running Sequel specs \e[32m#{'✔'}\e[0m"
rescue LoadError
  puts "sequel gem not found, not running Sequel specs \e[31m#{'✖'}\e[0m"
end
