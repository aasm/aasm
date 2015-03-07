module AASM

  class InvalidTransition < RuntimeError
    attr_reader :object, :event_name
    def initialize(object, event_name)
      @object, @event_name = object, event_name
    end

    def message
      "Event '#{event_name}' cannot transition from '#{object.aasm.current_state}'"
    end
  end

  class UndefinedState < RuntimeError; end
  class NoDirectAssignmentError < RuntimeError; end
end
