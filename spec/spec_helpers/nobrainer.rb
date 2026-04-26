# encoding: utf-8

begin
  require 'nobrainer'

  NoBrainer.configure do |config|
    config.app_name = :aasm
    config.environment = :test
    config.warn_on_active_record = false
  end

  puts "nobrainer #{Gem.loaded_specs['nobrainer'].version} gem found, running nobrainer specs \e[32m#{'✔'}\e[0m"
rescue LoadError
  puts "nobrainer gem not found, not running nobrainer specs \e[31m#{'✖'}\e[0m"
end
