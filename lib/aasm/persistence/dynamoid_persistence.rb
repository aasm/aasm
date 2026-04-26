module AASM
  module Persistence
    module DynamoidPersistence
      def self.included(base)
        base.send(:include, AASM::Persistence::Base)
        base.send(:include, AASM::Persistence::DynamoidPersistence::InstanceMethods)

        base.after_initialize :aasm_ensure_initial_state

        # Because Dynamoid only use define_method to add attribute assignment method in Class.
        #
        # In AASM::Base.initialize, it redefines and calls super in this method without superclass method.
        # We override method_missing to solve this problem.
        #
        base.class_eval %Q(
          def method_missing(method_name, *arguments, &block)
            if (AASM::StateMachineStore.fetch(self.class, true).machine_names.map { |state_machine_name| self.class.aasm(state_machine_name).attribute_name.to_s + "=" }).include? method_name.to_s
              attribute_name = method_name.to_s.gsub("=", '')
              write_attribute(attribute_name.to_sym, *arguments)
            else
              super
            end
          end
        )
      end

      module InstanceMethods

        # Writes <tt>state</tt> to the state column and persists it to the database
        # using update_attribute (which bypasses validation)
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
          write_attribute(self.class.aasm(name).attribute_name, state.to_s)

          unless self.save(:validate => false)
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
          write_attribute(self.class.aasm(name).attribute_name, state.to_s)
        end

      private

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
            aasm(state_machine_name).enter_initial_state if !send(self.class.aasm(state_machine_name).attribute_name) || send(self.class.aasm(state_machine_name).attribute_name).empty?
          end
        end
      end # InstanceMethods
    end
  end # Persistence
end # AASM
