module AASM
  module Persistence
    module PlainPersistence

      def aasm_read_state
        # all the following lines behave like @current_state ||= aasm.enter_initial_state
        current = aasm.instance_variable_get("@current_state")
        return current if current
        aasm.instance_variable_set("@current_state", aasm.enter_initial_state)
      end

      # may be overwritten by persistence mixins
      def aasm_write_state(new_state)
        true
      end

      # may be overwritten by persistence mixins
      def aasm_write_state_without_persistence(new_state)
        true
      end

    end
  end
end
