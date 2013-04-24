module AASM
  class InstanceBase

    def initialize(instance)
      @instance = instance
    end

    def current_state
      @current_state ||= @instance.aasm_read_state
    end

    def current_state=(state)
      if @instance.respond_to?(:aasm_write_state_without_persistence) || @instance.private_methods.include?('aasm_write_state_without_persistence')
        @instance.aasm_write_state_without_persistence(state)
      end
      @current_state = state
    end

    def enter_initial_state
      state_name = determine_state_name(@instance.class.aasm_initial_state)
      state_object = state_object_for_name(state_name)

      state_object.fire_callbacks(:before_enter, @instance)
      state_object.fire_callbacks(:enter, @instance)
      self.current_state = state_name
      state_object.fire_callbacks(:after_enter, @instance)

      state_name
    end

    def human_state
      AASM::Localizer.new.human_state_name(@instance.class, current_state)
    end

    # QUESTION: shouldn't events and permissible_events be the same thing?
    # QUESTION: shouldn't events return objects instead of strings?
    def events(state=current_state)
      events = @instance.class.aasm.events.values.select {|e| e.transitions_from_state?(state) }
      events.map {|e| e.name}
    end

    # filters the results of events_for_current_state so that only those that
    # are really currently possible (given transition guards) are shown.
    # QUESTION: what about events.permissible ?
    def permissible_events
      events.select{ |e| @instance.send(("may_" + e.to_s + "?").to_sym) }
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

    def set_current_state_with_persistence(state)
      save_success = true
      if @instance.respond_to?(:aasm_write_state) || @instance.private_methods.include?('aasm_write_state')
        save_success = @instance.aasm_write_state(state)
      end
      self.current_state = state if save_success
      save_success
    end

  end
end
