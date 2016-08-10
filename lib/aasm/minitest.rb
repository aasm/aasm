# relative-require all minitest_spec files
Dir[File.dirname(__FILE__) + '/minitest/*.rb'].each do |file|
  require 'aasm/minitest/' + File.basename(file, File.extname(file))
end
