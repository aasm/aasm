require 'aasm/persistence/orm'
module AASM
  module Persistence
    module ActiveRecordPersistence
      # This method:
      #
      # * extends the model with ClassMethods
      # * includes InstanceMethods
      #
      # Adds
      #
      #   after_initialize :aasm_ensure_initial_state
      #
      # As a result, it doesn't matter when you define your methods - the following 2 are equivalent
      #
      #   class Foo < ActiveRecord::Base
      #     def aasm_write_state(state)
      #       "bar"
      #     end
      #     include AASM
      #   end
      #
      #   class Foo < ActiveRecord::Base
      #     include AASM
      #     def aasm_write_state(state)
      #       "bar"
      #     end
      #   end
      #
      def self.included(base)
        base.send(:include, AASM::Persistence::Base)
        base.send(:include, AASM::Persistence::ORM)
        base.send(:include, AASM::Persistence::ActiveRecordPersistence::InstanceMethods)
        base.extend AASM::Persistence::ActiveRecordPersistence::ClassMethods

        base.after_initialize :aasm_ensure_initial_state

        # ensure state is in the list of states
        base.validate :aasm_validate_states
      end

      module ClassMethods
        def aasm_create_scope(state_machine_name, scope_name)
          if ActiveRecord::VERSION::MAJOR >= 3
            conditions = { aasm(state_machine_name).attribute_name => scope_name.to_s }
            class_eval do
              scope scope_name, lambda { where(table_name => conditions) }
            end
          else
            conditions = {
              table_name => { aasm(state_machine_name).attribute_name => scope_name.to_s }
            }
            class_eval do
              named_scope scope_name, :conditions => conditions
            end
          end
        end
      end

      module InstanceMethods

        private

        def aasm_raise_invalid_record
          raise ActiveRecord::RecordInvalid.new(self)
        end

        def aasm_save
          self.save
        end

        def aasm_update_column(attribute_name, value)
          self.class.unscoped.where(self.class.primary_key => self.id).update_all(attribute_name => value) == 1
        end

        def aasm_read_attribute(name)
          read_attribute(name)
        end

        def aasm_write_attribute(name, value)
          write_attribute(name, value)
        end

        def aasm_transaction(requires_new, requires_lock)
          self.class.transaction(:requires_new => requires_new) do
            lock!(requires_lock) if requires_lock
            yield
          end
        end

        def aasm_enum(name=:default)
          case AASM::StateMachineStore.fetch(self.class, true).machine(name).config.enum
          when false then nil
          when true then aasm_guess_enum_method(name)
          when nil then aasm_guess_enum_method(name) if aasm_column_looks_like_enum(name)
          else AASM::StateMachineStore.fetch(self.class, true).machine(name).config.enum
          end
        end

        def aasm_column_looks_like_enum(name=:default)
          column_name = self.class.aasm(name).attribute_name.to_s
          column = self.class.columns_hash[column_name]
          raise NoMethodError.new("undefined method '#{column_name}' for #{self.class}") if column.nil?
          column.type == :integer
        end

        def aasm_guess_enum_method(name=:default)
          self.class.aasm(name).attribute_name.to_s.pluralize.to_sym
        end

        def aasm_raw_attribute_value(state, name=:default)
          if aasm_enum(name)
            self.class.send(aasm_enum(name))[state]
          else
            super
          end
        end

        # Ensures that if the aasm_state column is nil and the record is new
        # then the initial state gets populated after initialization
        #
        #   foo = Foo.new
        #   foo.aasm_state # => "open" (where :open is the initial state)
        #
        #
        #   foo = Foo.find(:first)
        #   foo.aasm_state # => 1
        #   foo.aasm_state = nil
        #   foo.valid?
        #   foo.aasm_state # => nil
        #
        def aasm_ensure_initial_state
          AASM::StateMachineStore.fetch(self.class, true).machine_names.each do |state_machine_name|
            # checking via respond_to? does not work in Rails <= 3
            # if respond_to?(self.class.aasm(state_machine_name).attribute_name) && send(self.class.aasm(state_machine_name).attribute_name).blank? # Rails 4
            if aasm_column_is_blank?(state_machine_name)
              aasm(state_machine_name).enter_initial_state
            end
          end
        end

        def aasm_column_is_blank?(state_machine_name)
          attribute_name = self.class.aasm(state_machine_name).attribute_name
          attribute_names.include?(attribute_name.to_s) &&
            (send(attribute_name).respond_to?(:empty?) ? !!send(attribute_name).empty? : !send(attribute_name))
        end

        def aasm_validate_states
          AASM::StateMachineStore.fetch(self.class, true).machine_names.each do |state_machine_name|
            unless aasm_skipping_validations(state_machine_name)
              if aasm_invalid_state?(state_machine_name)
                self.errors.add(AASM::StateMachineStore.fetch(self.class, true).machine(state_machine_name).config.column , "is invalid")
              end
            end
          end
        end

        def aasm_invalid_state?(state_machine_name)
          aasm(state_machine_name).current_state && !aasm(state_machine_name).states.include?(aasm(state_machine_name).current_state)
        end
      end # InstanceMethods

    end
  end # Persistence
end # AASM
