require 'rails/generators/active_record'
require 'generators/aasm/orm_helpers'

module ActiveRecord
  module Generators
    class AASMGenerator < ActiveRecord::Generators::Base
      include AASM::Generators::OrmHelpers
      namespace "active_record:aasm"
      argument :column_name, type: :string, default: 'aasm_state'

      source_root File.expand_path("../templates", __FILE__)

      def copy_aasm_migration
        if column_exists?
          puts "Both model and column exists"
        elsif model_exists?
          migration_template "migration_existing.rb", "db/migrate/add_#{column_name}_to_#{table_name}.rb"
        else
          migration_template "migration.rb", "db/migrate/aasm_create_#{table_name}.rb"
        end
      end

      def generate_model
        invoke "active_record:model", [name], migration: false unless model_exists?
      end

      def inject_aasm_content
        content = model_contents

        class_path = if namespaced?
                       class_name.to_s.split("::")
                     else
                       [class_name]
                     end
        inject_into_class(model_path, class_path.last, content) if model_exists?
      end

    end
  end
end
