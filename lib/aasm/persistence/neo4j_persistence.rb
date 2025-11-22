require 'aasm/persistence/orm'

module AASM
  module Persistence
    module Neo4jPersistence
      def self.included(base)
        base.send(:include, AASM::Persistence::Base)
        base.send(:include, AASM::Persistence::ORM)
        base.send(:include, AASM::Persistence::Neo4jPersistence::InstanceMethods)

        base.after_initialize :aasm_ensure_initial_state
      end

      module InstanceMethods
        private

        def aasm_raise_invalid_record
          raise Neo4j::ActiveNode::Persistence::RecordInvalidError.new(self)
        end

        def aasm_save
          save
        end

        def aasm_read_attribute(name)
          read_attribute(name)
        end

        def aasm_write_attribute(name, value)
          write_attribute(name, value)
        end

        def aasm_ensure_initial_state
          AASM::StateMachineStore.fetch(self.class, true).machine_names.each do |state_machine_name|
            if aasm_column_is_blank?(state_machine_name)
              aasm(state_machine_name).enter_initial_state
            end
          end
        end

        def aasm_column_is_blank?(state_machine_name)
          attribute_name = self.class.aasm(state_machine_name).attribute_name
          attributes.include?(attribute_name.to_s) && send(attribute_name).blank?
        end
      end
    end
  end
end
