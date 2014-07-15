module AASM
  module Persistence
    module Base

      def self.included(base) #:nodoc:
        base.extend ClassMethods
      end

      # Returns the value of the aasm_column - called from <tt>aasm.current_state</tt>
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
      def aasm_read_state
        state = send(self.class.aasm_column)
        if new_record?
          state.blank? ? aasm.determine_state_name(self.class.aasm.initial_state) : state.to_sym
        else
          state.nil? ? nil : state.to_sym
        end
      end

      module ClassMethods
        # Maps to the aasm_column in the database.  Defaults to "aasm_state".  You can write
        # (example provided here for ActiveRecord, but it's true for Mongoid as well):
        #
        #   create_table :foos do |t|
        #     t.string :name
        #     t.string :aasm_state
        #   end
        #
        #   class Foo < ActiveRecord::Base
        #     include AASM
        #   end
        #
        # OR:
        #
        #   create_table :foos do |t|
        #     t.string :name
        #     t.string :status
        #   end
        #
        #   class Foo < ActiveRecord::Base
        #     include AASM
        #     aasm_column :status
        #   end
        #
        # This method is both a getter and a setter
        def aasm_column(column_name=nil)
          if column_name
            AASM::StateMachine[self].config.column = column_name.to_sym
            # @aasm_column = column_name.to_sym
          else
            AASM::StateMachine[self].config.column ||= :aasm_state
            # @aasm_column ||= :aasm_state
          end
          # @aasm_column
          AASM::StateMachine[self].config.column
        end
      end # ClassMethods

    end # Base
  end # Persistence

  class Base
    # make sure to create a (named) scope for each state
    def state_with_scope(name, *args)
      state_without_scope(name, *args)
      if AASM::StateMachine[@klass].config.create_scopes && !@klass.respond_to?(name)
        if @klass.ancestors.map {|klass| klass.to_s}.include?("ActiveRecord::Base")

          conditions = {"#{@klass.table_name}.#{@klass.aasm_column}" => name.to_s}
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
          scope_options = lambda { @klass.send(:where, {@klass.aasm_column.to_sym => name.to_s}) }
          @klass.send(:scope, name, scope_options)
        end
      end
    end
    alias_method :state_without_scope, :state
    alias_method :state, :state_with_scope
  end # Base

end # AASM
