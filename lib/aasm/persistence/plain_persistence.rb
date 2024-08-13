module AASM
  module Persistence
    module PlainPersistence

      # may be overwritten by persistence mixins
      def aasm_read_state(name=:default)
        # all the following lines behave like @current_state ||= aasm(name).enter_initial_state
        current = aasm(name).instance_variable_defined?("@current_state_#{name}") &&
                  aasm(name).instance_variable_get("@current_state_#{name}")
        return current if current
        aasm(name).instance_variable_set("@current_state_#{name}", aasm(name).enter_initial_state)
      end

      # may be overwritten by persistence mixins
      def aasm_write_state(new_state, name=:default)
        true
      end

      # may be overwritten by persistence mixins
      def aasm_write_state_without_persistence(new_state, name=:default)
        aasm(name).instance_variable_set("@current_state_#{name}", new_state)
      end

    end
  end
end
