# relative-require all rspec files
Dir[File.dirname(__FILE__) + '/rspec/*.rb'].each do |file|
  require 'aasm/rspec/' + File.basename(file, File.extname(file))
end

