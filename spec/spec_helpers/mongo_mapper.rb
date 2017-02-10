begin
  require 'mongo_mapper'
  puts "mongo_mapper gem found, running MongoMapper specs \e[32m#{'✔'}\e[0m"
rescue LoadError
  puts "mongo_mapper gem not found, not running MongoMapper specs \e[31m#{'✖'}\e[0m"
end
