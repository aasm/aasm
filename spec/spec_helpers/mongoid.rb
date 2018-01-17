# encoding: utf-8

begin
  require 'mongoid'
  puts "mongoid #{Mongoid::VERSION} gem found, running mongoid specs \e[32m#{'✔'}\e[0m"

  if Mongoid::VERSION.to_f <= 5
    Mongoid::Config.sessions = {
      default: {
        database: "mongoid_#{Process.pid}",
        hosts: ["#{ENV['MONGODB_HOST'] || 'localhost'}:" \
                "#{ENV['MONGODB_PORT'] || 27017}"]
      }
    }
  else
    Mongoid::Config.send(:clients=, {
      default: {
        database: "mongoid_#{Process.pid}",
        hosts: ["#{ENV['MONGODB_HOST'] || 'localhost'}:" \
                "#{ENV['MONGODB_PORT'] || 27017}"]
      }
    })
  end
rescue LoadError
  puts "mongoid gem not found, not running mongoid specs \e[31m#{'✖'}\e[0m"
end
