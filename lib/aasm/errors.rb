module AASM

  class UnknownStateMachineError < RuntimeError; end

  class InvalidTransition < RuntimeError
    attr_reader :object, :event_name, :state_machine_name

    def initialize(object, event_name, state_machine_name)
      @object, @event_name, @state_machine_name = object, event_name, state_machine_name
    end

    def message
      "Event '#{event_name}' cannot transition from '#{object.aasm(state_machine_name).current_state}'"
    end
  end

  class UndefinedState < RuntimeError; end
  class NoDirectAssignmentError < RuntimeError; end
end
