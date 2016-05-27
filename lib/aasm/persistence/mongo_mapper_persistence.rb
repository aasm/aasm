module AASM
  module Persistence
    module MongoMapperPersistence
      # This method:
      #
      # * extends the model with ClassMethods
      # * includes InstanceMethods
      #
      # Adds
      #
      #   before_validation :aasm_ensure_initial_state, :on => :create
      #
      # As a result, it doesn't matter when you define your methods - the following 2 are equivalent
      #
      #   class Foo
      #     include MongoMapper::Document
      #     def aasm_write_state(state)
      #       "bar"
      #     end
      #     include AASM
      #   end
      #
      #   class Foo < ActiveRecord::Base
      #     include MongoMapper::Document
      #     include AASM
      #     def aasm_write_state(state)
      #       "bar"
      #     end
      #   end
      #
      def self.included(base)
        base.send(:include, AASM::Persistence::Base)
        base.send(:include, AASM::Persistence::MongoMapperPersistence::InstanceMethods)
        base.extend AASM::Persistence::MongoMapperPersistence::ClassMethods

        base.before_create :aasm_ensure_initial_state

        # ensure state is in the list of states
        base.validate :aasm_validate_states
      end

      module ClassMethods
        def aasm_create_scope(state_machine_name, scope_name)
          conditions = { aasm(state_machine_name).attribute_name.to_sym => scope_name.to_s }
          scope(scope_name, lambda { where(conditions) })
        end
      end

      module InstanceMethods

        # Writes <tt>state</tt> to the state column and persists it to the database
        #
        #   foo = Foo.find(1)
        #   foo.aasm.current_state # => :opened
        #   foo.close!
        #   foo.aasm.current_state # => :closed
        #   Foo.find(1).aasm.current_state # => :closed
        #
        # NOTE: intended to be called from an event
        def aasm_write_state(state, name=:default)
          old_value = read_attribute(self.class.aasm(name).attribute_name)
          write_attribute(self.class.aasm(name).attribute_name, state)

          success = if aasm_skipping_validations(name)
            value = aasm_raw_attribute_value(state, name)
            self.class.where(self.class.primary_key => self.id).update_all(self.class.aasm(name).attribute_name => value) == 1
          else
            self.save
          end
          unless success
            write_attribute(self.class.aasm(name).attribute_name, old_value)
            return false
          end

          true
        end

        # Writes <tt>state</tt> to the state column, but does not persist it to the database
        #
        #   foo = Foo.find(1)
        #   foo.aasm.current_state # => :opened
        #   foo.close
        #   foo.aasm.current_state # => :closed
        #   Foo.find(1).aasm.current_state # => :opened
        #   foo.save
        #   foo.aasm.current_state # => :closed
        #   Foo.find(1).aasm.current_state # => :closed
        #
        # NOTE: intended to be called from an event
        def aasm_write_state_without_persistence(state, name=:default)
          aasm_write_attribute(state, name)
        end

        private
        def aasm_enum(name=:default)
          case AASM::StateMachineStore.fetch(self.class, true).machine(name).config.enum
          when false then nil
          when true then aasm_guess_enum_method(name)
          when nil then aasm_guess_enum_method(name) if aasm_column_looks_like_enum(name)
          else AASM::StateMachineStore.fetch(self.class, true).machine(name).config.enum
          end
        end

        def aasm_column_looks_like_enum(name)
          self.class.keys[self.class.aasm(name).attribute_name.to_s].type == Integer
        end

        def aasm_guess_enum_method(name)
          self.class.aasm(name).attribute_name.to_s.pluralize.to_sym
        end

        def aasm_skipping_validations(state_machine_name)
          AASM::StateMachineStore.fetch(self.class, true).machine(state_machine_name).config.skip_validation_on_save
        end

        def aasm_write_attribute(state, name=:default)
          write_attribute self.class.aasm(name).attribute_name, aasm_raw_attribute_value(state, name)
        end

        def aasm_raw_attribute_value(state, name=:default)
          if aasm_enum(name)
            self.class.send(aasm_enum(name))[state]
          else
            state.to_s
          end
        end

        # Ensures that if the aasm_state column is nil and the record is new
        # that the initial state gets populated before validation on create
        #
        #   foo = Foo.new
        #   foo.aasm_state # => nil
        #   foo.valid?
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
            send("#{self.class.aasm(state_machine_name).attribute_name}=", aasm(state_machine_name).enter_initial_state.to_s) if send(self.class.aasm(state_machine_name).attribute_name).blank?
          end
        end

        def aasm_validate_states
          AASM::StateMachineStore.fetch(self.class, true).machine_names.each do |state_machine_name|
            send("#{self.class.aasm(state_machine_name).attribute_name}=", aasm(state_machine_name).enter_initial_state.to_s) if send(self.class.aasm(state_machine_name).attribute_name).blank?
            unless AASM::StateMachineStore.fetch(self.class, true).machine(state_machine_name).config.skip_validation_on_save
              if aasm(state_machine_name).current_state && !aasm(state_machine_name).states.include?(aasm(state_machine_name).current_state)
                self.errors.add(AASM::StateMachineStore.fetch(self.class, true).machine(state_machine_name).config.column , "is invalid")
              end
            end
          end
        end
      end # InstanceMethods

    end
  end # Persistence
end # AASM
