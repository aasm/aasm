# relative-require all minitest_spec files
Dir[File.dirname(__FILE__) + '/minitest_spec/*.rb'].each do |file|
  require 'aasm/minitest_spec/' + File.basename(file, File.extname(file))
end
