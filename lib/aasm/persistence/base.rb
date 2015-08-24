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
    def state_with_scope(name, *args)
      state_without_scope(name, *args)
      if @state_machine.config.create_scopes && !@klass.respond_to?(name)
        if @klass.ancestors.map {|klass| klass.to_s}.include?("ActiveRecord::Base")

          conditions = {"#{@klass.table_name}.#{@klass.aasm(@name).attribute_name}" => name.to_s}
          if ActiveRecord::VERSION::MAJOR >= 3
            @klass.class_eval do
              scope name, lambda { where(conditions) }
            end
          else
            @klass.class_eval do
              named_scope name, :conditions => conditions
            end
          end
        elsif @klass.ancestors.map {|klass| klass.to_s}.include?("Mongoid::Document")
          scope_options = lambda { @klass.send(:where, {@klass.aasm(@name).attribute_name.to_sym => name.to_s}) }
          @klass.send(:scope, name, scope_options)
        elsif @klass.ancestors.map {|klass| klass.to_s}.include?("MongoMapper::Document")
          conditions = { @klass.aasm(@name).attribute_name.to_sym => name.to_s }
          @klass.scope(name, lambda { @klass.where(conditions) })
        end
      end
    end
    alias_method :state_without_scope, :state
    alias_method :state, :state_with_scope
  end # Base

end # AASM
