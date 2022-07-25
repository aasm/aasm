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
    end

    def enter_initial_state
      state_name = determine_state_name(@instance.class.aasm(@name).initial_state)
      state_object = state_object_for_name(state_name)

      state_object.fire_callbacks(:before_enter, @instance)
      self.current_state = state_name
      state_object.fire_callbacks(:after_enter, @instance)

      state_name
    end

    def human_state
      state_object_for_name(current_state).display_name
    end

    def states(options={}, *args)
      if options.has_key?(:permitted)
        selected_events = events({:permitted => options[:permitted]}, *args)
        # An array of arrays. Each inner array represents the transitions that
        # transition from the current state for an event
        event_transitions = selected_events.map {|e| e.transitions_from_state(current_state) }

        # An array of :to transition states
        to_state_names = event_transitions.map do |transitions|
          return nil if transitions.empty?

          # Return the :to state of the first transition that is allowed (or not) or nil
          if options[:permitted]
            transition = transitions.find { |t| t.allowed?(@instance, *args) }
          else
            transition = transitions.find { |t| !t.allowed?(@instance, *args) }
          end
          transition ? transition.to : nil
        end.flatten.compact.uniq

        # Select states that are in to_state_names
        @instance.class.aasm(@name).states.select {|s| to_state_names.include?(s.name)}
      else
        @instance.class.aasm(@name).states
      end
    end

    def events(options={}, *args)
      state = options[:state] || current_state
      events = @instance.class.aasm(@name).events.select {|e| e.transitions_from_state?(state) }

      options[:reject] = Array(options[:reject])
      events.reject! { |e| options[:reject].include?(e.name) }

      if options.has_key?(:permitted)
        # filters the results of events_for_current_state so that only those that
        # are really currently possible (given transition guards) are shown.
        if options[:permitted]
          events.select! { |e| @instance.send("may_#{e.name}?", *args) }
        else
          events.select! { |e| !@instance.send("may_#{e.name}?", *args) }
        end
      end

      events
    end

    def permitted_transitions
      events(permitted: true).flat_map do |event|
        available_transitions = event.transitions_from_state(current_state)
        allowed_transitions = available_transitions.select { |t| t.allowed?(@instance) }

        allowed_transitions.map do |transition|
          { event: event.name, state: transition.to }
        end
      end
    end

    def state_object_for_name(name)
      obj = @instance.class.aasm(@name).states.find {|s| s.name == name}
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
          raise NotImplementedError, "Unrecognized state-type given. Expected Symbol, String, or Proc."
      end
    end

    def may_fire_event?(name, *args)
      if event = @instance.class.aasm(@name).state_machine.events[name]
        !!event.may_fire?(@instance, *args)
      else
        false # unknown event
      end
    end

    def fire(event_name, *args, &block)
      event_exists?(event_name)

      @instance.send(event_name, *args, &block)
    end

    def fire!(event_name, *args, &block)
      event_exists?(event_name, true)
      bang_event_name = "#{event_name}!".to_sym
      @instance.send(bang_event_name, *args, &block)
    end

    def set_current_state_with_persistence(state)
      save_success = @instance.aasm_write_state(state, @name)
      self.current_state = state if save_success
      save_success
    end

    private

    def event_exists?(event_name, bang = false)
      event = @instance.class.aasm(@name).state_machine.events[event_name.to_sym]
      return true if event

      event_error = bang ? "#{event_name}!" : event_name
      raise AASM::UndefinedEvent, "Event :#{event_error} doesn't exist" if event.nil?
    end
  end
end
