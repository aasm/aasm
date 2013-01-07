module AASM
  module Persistence
    module Base

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
      end

    end # Base
  end # Persistence

  class Base
    def state_with_scope(name, *args)
      state_without_scope(name, *args)
      unless @clazz.respond_to?(name)
        if @clazz.ancestors.map {|klass| klass.to_s}.include?("ActiveRecord::Base")
          scope_options = {:conditions => { "#{@clazz.table_name}.#{@clazz.aasm_column}" => name.to_s}}
          scope_method = ActiveRecord::VERSION::MAJOR >= 3 ? :scope : :named_scope
          @clazz.send(scope_method, name, scope_options)
        elsif @clazz.ancestors.map {|klass| klass.to_s}.include?("Mongoid::Document")
          scope_options = lambda { @clazz.send(:where, {@clazz.aasm_column.to_sym => name.to_s}) }
          @clazz.send(:scope, name, scope_options)
        end
      end
    end
    alias_method :state_without_scope, :state
    alias_method :state, :state_with_scope
  end # Base

end # AASM
