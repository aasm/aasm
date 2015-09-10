module AASM
  class InstanceBase

    attr_accessor :from_state, :to_state, :current_event

    def initialize(instance, name=:default) # instance of the class including AASM, name of the state machine
      @instance = instance
      @name = name
    end

    def current_state
      @instance.aasm_read_state(@name)
    end

    def current_state=(state)
      @instance.aasm_write_state_without_persistence(state, @name)
      # @current_state = state
    end

    def enter_initial_state
      state_name = determine_state_name(@instance.class.aasm(@name).initial_state)
      state_object = state_object_for_name(state_name)

      state_object.fire_callbacks(:before_enter, @instance)
      # state_object.fire_callbacks(:enter, @instance)
      self.current_state = state_name
      state_object.fire_callbacks(:after_enter, @instance)

      state_name
    end

    def human_state
      AASM::Localizer.new.human_state_name(@instance.class, state_object_for_name(current_state))
    end

    def states(options={})
      if options[:permitted]
        # ugliness level 1000
        permitted_event_names = events(:permitted => true).map(&:name)
        transitions = @instance.class.aasm(@name).state_machine.events.values_at(*permitted_event_names).compact.map {|e| e.transitions_from_state(current_state) }
        tos = transitions.map {|t| t[0] ? t[0].to : nil}.flatten.compact.map(&:to_sym).uniq
        @instance.class.aasm(@name).states.select {|s| tos.include?(s.name.to_sym)}
      else
        @instance.class.aasm(@name).states
      end
    end

    def events(options={})
      state = options[:state] || current_state
      events = @instance.class.aasm(@name).events.select {|e| e.transitions_from_state?(state) }

      if options[:permitted]
        # filters the results of events_for_current_state so that only those that
        # are really currently possible (given transition guards) are shown.
        events.select! { |e| @instance.send("may_#{e.name}?") }
      end

      events
    end

    def state_object_for_name(name)
      obj = @instance.class.aasm(@name).states.find {|s| s == name}
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
      if event = @instance.class.aasm(@name).state_machine.events[name]
        !!event.may_fire?(@instance, *args)
      else
        false # unknown event
      end
    end

    def set_current_state_with_persistence(state)
      save_success = @instance.aasm_write_state(state, @name)
      self.current_state = state if save_success
      save_success
    end

  end
end
