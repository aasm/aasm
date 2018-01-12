$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec', 'models')))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))
require 'aasm'
require 'minitest/autorun'
require 'aasm/minitest_spec'
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

# Dynamoid initialization
begin
  require 'dynamoid'
  require 'aws-sdk-resources'

  ENV['ACCESS_KEY'] ||= 'abcd'
  ENV['SECRET_KEY'] ||= '1234'

  Aws.config.update({
    region: 'us-west-2',
    credentials: Aws::Credentials.new(ENV['ACCESS_KEY'], ENV['SECRET_KEY'])
  })

  Dynamoid.configure do |config|
    config.namespace = 'dynamoid_tests'
    config.endpoint = "http://#{ENV['DYNAMODB_HOST'] || '127.0.0.1'}:30180"
    config.warn_on_scan = false
  end

  Dynamoid.logger.level = Logger::FATAL

  class Minitest::Spec
    before do
      Dynamoid.adapter.list_tables.each do |table|
        Dynamoid.adapter.delete_table(table) if table =~ /^#{Dynamoid::Config.namespace}/
      end
      Dynamoid.adapter.tables.clear
    end
  end
rescue LoadError
  # Without Dynamoid settings
end

# example model classes
Dir[File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec', 'models')) + '/*.rb'].sort.each { |f| require File.expand_path(f) }
