# encoding: utf-8

begin
  require 'dynamoid'
  require 'aws-sdk-resources'
  puts "dynamoid #{Dynamoid::VERSION} gem found, running Dynamoid specs \e[32m#{'✔'}\e[0m"

  ENV['ACCESS_KEY'] ||= 'abcd'
  ENV['SECRET_KEY'] ||= '1234'

  Aws.config.update(
    region: 'us-west-2',
    credentials: Aws::Credentials.new(ENV['ACCESS_KEY'], ENV['SECRET_KEY'])
  )

  Dynamoid.configure do |config|
    config.namespace = 'dynamoid_tests'
    config.endpoint = "http://#{ENV['DYNAMODB_HOST'] || '127.0.0.1'}:" \
                      "#{ENV['DYNAMODB_PORT'] || 30180}"
    config.warn_on_scan = false
  end

  Dynamoid.logger.level = Logger::FATAL

  RSpec.configure do |c|
    c.before(:each) do
      Dynamoid.adapter.list_tables.each do |table|
        Dynamoid.adapter.delete_table(table) if table =~ /^#{Dynamoid::Config.namespace}/
      end
      Dynamoid.adapter.tables.clear
    end
  end
rescue LoadError
  puts "dynamoid gem not found, not running Dynamoid specs \e[31m#{'✖'}\e[0m"
end
