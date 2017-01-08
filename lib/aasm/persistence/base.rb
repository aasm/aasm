module AASM
  module Persistence
    module Base

      def self.included(base) #:nodoc:
        base.extend ClassMethods
      end

      # Returns the value of the aasm.attribute_name - called from <tt>aasm.current_state</tt>
      #
      # If it's a new record, and the aasm state column is blank it returns the initial state
      # (example provided here for ActiveRecord, but it's true for Mongoid as well):
      #
      #   class Foo < ActiveRecord::Base
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
      #   foo = Foo.find(1)
      #   foo.current_state # => :opened
      #   foo.aasm_state = nil
      #   foo.current_state # => nil
      #
      # NOTE: intended to be called from an event
      #
      # This allows for nil aasm states - be sure to add validation to your model
      def aasm_read_state(name=:default)
        state = send(self.class.aasm(name).attribute_name)
        if new_record?
          state.blank? ? aasm(name).determine_state_name(self.class.aasm(name).initial_state) : state.to_sym
        else
          state.blank? ? nil : state.to_sym
        end
      end

      def aasm_update_timestamp(state, name)
        if aasm_update_timestamp?(state, name)
          write_attribute(aasm_timestamp_name(state, name), ::DateTime.now)
        end
      end

      def aasm_update_timestamp?(state, name)
        !state.to_s.empty? && aasm_timestamp(state, name)
      end

      def aasm_timestamp_name(state, name)
        ts = aasm_timestamp(state, name)
        case ts
          when Symbol, String
            ts
          when TrueClass
            "#{state}_at"
          else
            nil
        end
      end

      def aasm_timestamp(state, name)
        self.aasm(name).state_object_for_name(state.to_s.to_sym).options[:timestamp]
      end

      module ClassMethods
        def aasm_column(attribute_name=nil)
          warn "[DEPRECATION] aasm_column is deprecated. Use aasm.attribute_name instead"
          aasm.attribute_name(attribute_name)
        end
      end # ClassMethods

    end # Base
  end # Persistence

  class Base
    # make sure to create a (named) scope for each state
    def state_with_scope(*args)
      names = state_without_scope(*args)
      names.each { |name| create_scope(name) if create_scope?(name) }
    end
    alias_method :state_without_scope, :state
    alias_method :state, :state_with_scope

    private

    def create_scope?(name)
      @state_machine.config.create_scopes && !@klass.respond_to?(name) && @klass.respond_to?(:aasm_create_scope)
    end

    def create_scope(name)
      @klass.aasm_create_scope(@name, name)
    end

  end # Base

end # AASM
