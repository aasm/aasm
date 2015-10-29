# Requires
require 'rails/generators'
require 'rails/generators/migration'

class AasmGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  def self.source_root
    @source_root ||= File.join(File.dirname(__FILE__), 'templates')
  end

  def self.next_migration_number(dirname)
    if ActiveRecord::Base.timestamped_migrations
      Time.new.utc.strftime("%Y%m%d%H%M%S")
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end
  end

  def create_migration_file
    unless self.class.migration_exists?("db/migrate", "create_aasm_state_change_logs").present?
      migration_template "create_aasm_state_change_logs.rb", "db/migrate/create_aasm_state_change_logs.rb"
    end
  end
end
