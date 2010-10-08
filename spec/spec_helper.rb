$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))

require 'aasm'

require 'spec'
require 'spec/autorun'

require 'ruby-debug'; Debugger.settings[:autoeval] = true; debugger; rubys_debugger = 'annoying'
require 'ruby-debug/completion'

Spec::Runner.configure do |config|
  
end
