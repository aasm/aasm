module AASM
  module Persistence
    module RedisPersistence

      def self.included(base)
        base.send(:include, AASM::Persistence::Base)
        base.send(:include, AASM::Persistence::RedisPersistence::InstanceMethods)
      end

      module InstanceMethods
        # Add the inital value to intiializer
        #
        # redis-objects removed the key from redis when set to nil
        def initialize(*args)
          super
          state = send(self.class.aasm.attribute_name)
          state.value = aasm.determine_state_name(self.class.aasm.initial_state)
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
          aasm.enter_initial_state if
          send(self.class.aasm.attribute_name).to_s.strip.empty?
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
        def aasm_write_state(state)
          aasm_column = self.class.aasm.attribute_name
          self.send("#{aasm_column}=", state)
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
        def aasm_write_state_without_persistence(state)
          send("#{self.class.aasm.attribute_name}=", state)
        end
      end
    end
  end
end
