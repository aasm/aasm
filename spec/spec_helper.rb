$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))
require 'aasm'
require 'rspec'
require 'aasm/rspec'
require 'pry'

# require 'ruby-debug'; Debugger.settings[:autoeval] = true; debugger; rubys_debugger = 'annoying'
# require 'ruby-debug/completion'
# require 'pry'

SEQUEL_DB = defined?(JRUBY_VERSION) ? 'jdbc:sqlite::memory:' : 'sqlite:/'

def load_schema
  require 'logger'
  config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
  ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
  ActiveRecord::Base.establish_connection(config['sqlite3'])
  require File.dirname(__FILE__) + "/database.rb"
end

# custom spec helpers
Dir[File.dirname(__FILE__) + "/spec_helpers/**/*.rb"].sort.each { |f| require File.expand_path(f) }

# example model classes
Dir[File.dirname(__FILE__) + "/models/*.rb"].sort.each { |f| require File.expand_path(f) }
