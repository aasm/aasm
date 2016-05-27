require 'rails/generators/named_base'
require 'generators/aasm/orm_helpers'

module Mongoid
  module Generators
    class AASMGenerator < Rails::Generators::NamedBase
      include AASM::Generators::OrmHelpers
      namespace "mongoid:aasm"
      argument :column_name, type: :string, default: 'aasm_state'

      def generate_model
        invoke "mongoid:model", [name] unless model_exists?
      end

      def inject_aasm_content
        inject_into_file model_path, model_contents, after: "include Mongoid::Document\n" if model_exists?
      end

      def inject_field_types
        inject_into_file model_path, migration_data, after: "include Mongoid::Document\n" if model_exists?
      end

      def migration_data
        "  field :#{column_name}"
      end
    end
  end
end
