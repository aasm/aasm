module AASM
  module Persistence
    # This module adds transactional support for any database that supports it.
    # This includes rollback capability and rollback/commit callbacks.
    module ORM

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
        attribute_name = self.class.aasm(name).attribute_name
        old_value = aasm_read_attribute(attribute_name)
        aasm_write_state_attribute state, name

        success = if aasm_skipping_validations(name)
          aasm_update_column(attribute_name, aasm_raw_attribute_value(state, name))
        else
          aasm_save
        end

        unless success
          aasm_rollback(name, old_value)
          aasm_raise_invalid_record if aasm_whiny_persistence(name)
        end

        success
      end

      # Writes <tt>state</tt> to the state field, but does not persist it to the database
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
        aasm_write_state_attribute(state, name)
      end

      private

      # Save the record and return true if it succeeded/false otherwise.
      def aasm_save
        raise("Define #aasm_save_without_error in the AASM Persistence class.")
      end

      def aasm_raise_invalid_record
        raise("Define #aasm_raise_invalid_record in the AASM Persistence class.")
      end

      # Update only the column without running validations.
      def aasm_update_column(attribute_name, value)
        raise("Define #aasm_update_column in the AASM Persistence class.")
      end

      def aasm_read_attribute(name)
        raise("Define #aasm_read_attribute the AASM Persistence class.")
      end

      def aasm_write_attribute(name, value)
        raise("Define #aasm_write_attribute in the AASM Persistence class.")
      end

      # Returns true or false if transaction completed successfully.
      def aasm_transaction(requires_new, requires_lock)
        raise("Define #aasm_transaction the AASM Persistence class.")
      end

      def aasm_supports_transactions?
        true
      end

      def aasm_write_state_attribute(state, name=:default)
        aasm_write_attribute(self.class.aasm(name).attribute_name, aasm_raw_attribute_value(state, name))
      end

      def aasm_raw_attribute_value(state, _name=:default)
        state.to_s
      end

      def aasm_rollback(name, old_value)
        aasm_write_attribute(self.class.aasm(name).attribute_name, old_value)
        false
      end

      def aasm_whiny_persistence(state_machine_name)
        AASM::StateMachineStore.fetch(self.class, true).machine(state_machine_name).config.whiny_persistence
      end

      def aasm_skipping_validations(state_machine_name)
        AASM::StateMachineStore.fetch(self.class, true).machine(state_machine_name).config.skip_validation_on_save
      end

      def use_transactions?(state_machine_name)
        AASM::StateMachineStore.fetch(self.class, true).machine(state_machine_name).config.use_transactions
      end

      def requires_new?(state_machine_name)
        AASM::StateMachineStore.fetch(self.class, true).machine(state_machine_name).config.requires_new_transaction
      end

      def requires_lock?(state_machine_name)
        AASM::StateMachineStore.fetch(self.class, true).machine(state_machine_name).config.requires_lock
      end

      # Returns true if event was fired successfully and transaction completed.
      def aasm_fire_event(state_machine_name, name, options, *args, &block)
        if aasm_supports_transactions? && options[:persist]
          event = self.class.aasm(state_machine_name).state_machine.events[name]
          event.fire_callbacks(:before_transaction, self, *args)
          event.fire_global_callbacks(:before_all_transactions, self, *args)

          begin
            success = if options[:persist] && use_transactions?(state_machine_name)
              aasm_transaction(requires_new?(state_machine_name), requires_lock?(state_machine_name)) do
                super
              end
            else
              super
            end

            if success
              event.fire_callbacks(:after_commit, self, *args)
              event.fire_global_callbacks(:after_all_commits, self, *args)
            end

            success
          ensure
            event.fire_callbacks(:after_transaction, self, *args)
            event.fire_global_callbacks(:after_all_transactions, self, *args)
          end
        else
          super
        end
      end

    end # Transactional
  end # Persistence
end # AASM
