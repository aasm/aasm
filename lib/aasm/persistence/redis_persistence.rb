module AASM
  module Persistence
    module RedisPersistence

      def self.included(base)
        base.send(:include, AASM::Persistence::Base)
        base.send(:include, AASM::Persistence::RedisPersistence::InstanceMethods)
      end

      module InstanceMethods
        # Initialize with default values
        #
        # Redis::Objects removes the key from Redis when set to `nil`
        def initialize(*args)
          super
          aasm_ensure_initial_state
        end
        # Returns the value of the aasm.attribute_name - called from <tt>aasm.current_state</tt>
        #
        # If it's a new record, and the aasm state column is blank it returns the initial state
        #
        #   class Foo
        #     include Redis::Objects
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

          if state.value.nil?
            nil
          else
            state.value.to_sym
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
          AASM::StateMachineStore.fetch(self.class, true).machine_names.each do |name|
            aasm_column = self.class.aasm(name).attribute_name
            aasm(name).enter_initial_state if !send(aasm_column).value || send(aasm_column).value.empty?
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
        def aasm_write_state(state, name=:default)
          aasm_column = self.class.aasm(name).attribute_name
          send("#{aasm_column}").value = state
        end

        # Writes <tt>state</tt> to the state column, but does not persist it to the database
        # (but actually it still does)
        #
        # With Redis::Objects it's not possible to skip persisting - it's not an ORM,
        # it does not operate like an AR model and does not know how to postpone changes.
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
        def aasm_write_state_without_persistence(state, name=:default)
          aasm_write_state(state, name)
        end
      end
    end
  end
end
