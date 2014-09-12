module AASM
  class InstanceBase

    attr_accessor :from_state, :to_state, :current_event

    def initialize(instance)
      @instance = instance
    end

    def current_state
      @instance.aasm_read_state
    end

    def current_state=(state)
      @instance.aasm_write_state_without_persistence(state)
      @current_state = state
    end

    def enter_initial_state
      state_name = determine_state_name(@instance.class.aasm.initial_state)
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

    def states(options={})
      if options[:permissible]
        # ugliness level 1000
        transitions = @instance.class.aasm.events.values_at(*permissible_events).compact.map {|e| e.transitions_from_state(current_state) }
        tos = transitions.map {|t| t[0] ? t[0].to : nil}.flatten.compact.map(&:to_sym).uniq
        @instance.class.aasm.states.select {|s| tos.include?(s.name.to_sym)}
      else
        @instance.class.aasm.states
      end
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
      if event = @instance.class.aasm.events[name]
        event.may_fire?(@instance, *args)
      else
        false # unknown event
      end
    end

    def set_current_state_with_persistence(state)
      save_success = @instance.aasm_write_state(state)
      self.current_state = state if save_success
      save_success
    end

  end
end
