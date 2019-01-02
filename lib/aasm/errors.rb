module AASM

  class UnknownStateMachineError < RuntimeError; end

  class InvalidTransition < RuntimeError
    attr_reader :object, :event_name, :originating_state, :failures, :state_machine_name

    def initialize(object, event_name, state_machine_name, failures = [])
      @object, @event_name, @originating_state, @failures = object, event_name, object.aasm(state_machine_name).current_state, failures
      @state_machine_name = state_machine_name
      super("Event '#{event_name}' cannot transition from '#{originating_state}'.#{reasoning}")
    end

    def reasoning
      " Failed callback(s): #{failures}." unless failures.empty?
    end
  end

  class UndefinedState < RuntimeError; end
  class NoDirectAssignmentError < RuntimeError; end
end
