require 'rails/generators/named_base'
require 'generators/aasm/orm_helpers'

module NoBrainer
  module Generators
    class AASMGenerator < Rails::Generators::NamedBase
      include AASM::Generators::OrmHelpers
      namespace 'nobrainer:aasm'
      argument :column_name, type: :string, default: 'aasm_state'

      def generate_model
        invoke 'nobrainer:model', [name] unless model_exists?
      end

      def inject_aasm_content
        inject_into_file model_path, model_contents, after: "include NoBrainer::Document::Timestamps\n" if model_exists?
      end

      def inject_field_types
        inject_into_file model_path, migration_data, after: "include NoBrainer::Document::Timestamps\n" if model_exists?
      end

      def migration_data
        "  field :#{column_name}"
      end
    end
  end
end
