module AASM
  module Persistence
    module SequelPersistence
      def self.included(base)
        base.send(:include, AASM::Persistence::Base)
        base.send(:include, AASM::Persistence::SequelPersistence::InstanceMethods)
      end

      module InstanceMethods
        def before_validation
          aasm_ensure_initial_state
          super
        end

        def before_create
          aasm_ensure_initial_state
          super
        end

        # Returns the value of the aasm.attribute_name - called from <tt>aasm.current_state</tt>
        #
        # If it's a new record, and the aasm state column is blank it returns the initial state
        #
        #   class Foo < Sequel::Model
        #     include AASM
        #     aasm :column => :status do
        #       state :opened
        #       state :closed
        #     end
        #   end
        #
        #   foo = Foo.new
        #   foo.current_state # => :opened
        #   foo.close
        #   foo.current_state # => :closed
        #
        #   foo = Foo[1]
        #   foo.current_state # => :opened
        #   foo.aasm_state = nil
        #   foo.current_state # => nil
        #
        # NOTE: intended to be called from an event
        #
        # This allows for nil aasm states - be sure to add validation to your model
        def aasm_read_state(name=:default)
          state = send(self.class.aasm(name).attribute_name)
          if new? && state.to_s.strip.empty?
            aasm(name).determine_state_name(self.class.aasm(name).initial_state)
          elsif state.nil?
            nil
          else
            state.to_sym
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
            aasm(state_machine_name).enter_initial_state if
              (new? || values.key?(self.class.aasm(state_machine_name).attribute_name)) &&
              send(self.class.aasm(state_machine_name).attribute_name).to_s.strip.empty?
          end
        end

        # Writes <tt>state</tt> to the state column and persists it to the database
        #
        #   foo = Foo[1]
        #   foo.aasm.current_state # => :opened
        #   foo.close!
        #   foo.aasm.current_state # => :closed
        #   Foo[1].aasm.current_state # => :closed
        #
        # NOTE: intended to be called from an event
        def aasm_write_state state, name=:default
          aasm_column = self.class.aasm(name).attribute_name
          update_only({aasm_column => state.to_s}, aasm_column)
        end

        # Writes <tt>state</tt> to the state column, but does not persist it to the database
        #
        #   foo = Foo[1]
        #   foo.aasm.current_state # => :opened
        #   foo.close
        #   foo.aasm.current_state # => :closed
        #   Foo[1].aasm.current_state # => :opened
        #   foo.save
        #   foo.aasm.current_state # => :closed
        #   Foo[1].aasm.current_state # => :closed
        #
        # NOTE: intended to be called from an event
        def aasm_write_state_without_persistence state, name=:default
          send("#{self.class.aasm(name).attribute_name}=", state.to_s)
        end
      end
    end
  end
end
