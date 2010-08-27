$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))

require 'aasm'

require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  
end
