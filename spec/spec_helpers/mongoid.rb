# encoding: utf-8
begin
  require 'mongoid'
  puts "mongoid gem found, running mongoid specs \e[32m#{'✔'}\e[0m"
rescue LoadError
  puts "mongoid gem not found, not running mongoid specs \e[31m#{'✖'}\e[0m"
end
