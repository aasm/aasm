module AASM
  class InstanceBase

    def initialize(instance)
      @instance = instance
    end

    def current_state
      @current_state ||= persistable? ? @instance.aasm_read_state : @instance.aasm_enter_initial_state
    end

    def current_state=(state)
      if @instance.respond_to?(:aasm_write_state_without_persistence) || @instance.private_methods.include?('aasm_write_state_without_persistence')
        @instance.aasm_write_state_without_persistence(state)
      end
      @current_state = state
    end

    def human_state
      AASM::Localizer.new.human_state_name(@instance.class, current_state)
    end

    def events(state=current_state)
      events = @instance.class.aasm_events.values.select {|e| e.transitions_from_state?(state) }
      events.map {|e| e.name}
    end

    def state_object_for_name(name)
      obj = @instance.class.aasm.states.find {|s| s == name}
      raise AASM::UndefinedState, "State :#{name} doesn't exist" if obj.nil?
      obj
    end

    def determine_state_name(state)
      case state
        when Symbol, String
          state
        when Proc
          state.call(@instance)
        else
          raise NotImplementedError, "Unrecognized state-type given.  Expected Symbol, String, or Proc."
      end
    end

    def may_fire_event?(name, *args)
      event = @instance.class.aasm.events[name]
      event.may_fire?(@instance, *args)
    end

  private

    def persistable?
      @instance.respond_to?(:aasm_read_state) || @instance.private_methods.include?('aasm_read_state')
    end

  end
end
