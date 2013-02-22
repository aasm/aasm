module AASM

  def self.included(base) #:nodoc:
    base.extend AASM::ClassMethods
    AASM::StateMachine[base] ||= AASM::StateMachine.new('')
    AASM::Persistence.set_persistence(base)
    super
  end

  module ClassMethods

    # make sure inheritance (aka subclassing) works with AASM
    def inherited(base)
      AASM::StateMachine[base] = AASM::StateMachine[self].clone
      super
    end

    # this is the entry point for all state and event definitions
    def aasm(options={}, &block)
      @aasm ||= AASM::Base.new(self, options)
      @aasm.instance_eval(&block) if block # new DSL
      @aasm
    end

    # TODO: maybe better: aasm.initial_state
    def aasm_initial_state(set_state=nil)
      if set_state
        # deprecated way to set the value
        AASM::StateMachine[self].initial_state = set_state
      else
        AASM::StateMachine[self].initial_state
      end
    end

    # is this better?: aasm.states.name.from_states
    def aasm_from_states_for_state(state, options={})
      if options[:transition]
        aasm.events[options[:transition]].transitions_to_state(state).flatten.map(&:from).flatten
      else
        aasm.events.map {|k,v| v.transitions_to_state(state)}.flatten.map(&:from).flatten
      end
    end

    # deprecated
    def aasm_initial_state=(state)
      AASM::StateMachine[self].initial_state = state
    end

    # deprecated
    def aasm_state(name, options={})
      aasm.state(name, options)
    end

    # deprecated
    def aasm_event(name, options = {}, &block)
      aasm.event(name, options, &block)
    end

    # deprecated
    def aasm_states
      aasm.states
    end

    # deprecated
    def aasm_events
      aasm.events
    end

    # deprecated
    def aasm_states_for_select
      aasm.states_for_select
    end

    # aasm.event(:event_name).human?
    def aasm_human_event_name(event) # event_name?
      AASM::Localizer.new.human_event_name(self, event)
    end
  end # ClassMethods

  def aasm
    @aasm ||= AASM::InstanceBase.new(self)
  end

  # deprecated
  def aasm_current_state
    # warn "#aasm_current_state is deprecated and will be removed in version 3.2.0; please use #aasm.state instead!"
    aasm.current_state
  end

  # deprecated
  def aasm_enter_initial_state
    # warn "#aasm_enter_initial_state is deprecated and will be removed in version 3.2.0; please use #aasm.enter_initial_state instead!"
    aasm.enter_initial_state
  end

  # deprecated
  def aasm_events_for_current_state
    # warn "#aasm_events_for_current_state is deprecated and will be removed in version 3.2.0; please use #aasm.events instead!"
    aasm.events(aasm.current_state)
  end

  # deprecated
  def aasm_permissible_events_for_current_state
    # warn "#aasm_permissible_events_for_current_state is deprecated and will be removed in version 3.2.0; please use #aasm.permissible_events instead!"
    aasm.permissible_events
  end

  # deprecated
  def aasm_events_for_state(state_name)
    # warn "#aasm_events_for_state(state_name) is deprecated and will be removed in version 3.2.0; please use #aasm.events(state_name) instead!"
    aasm.events(state_name)
  end

  # deprecated
  def aasm_human_state
    # warn "#aasm_human_state is deprecated and will be removed in version 3.2.0; please use #aasm.human_state instead!"
    aasm.human_state
  end

private

  def aasm_fire_event(name, options, *args)
    persist = options[:persist]

    event = self.class.aasm_events[name]
    begin
      old_state = aasm.state_object_for_name(aasm.current_state)


      old_state.fire_callbacks(:exit, self)

      # new event before callback
      event.fire_callbacks(:before, self)

      if new_state_name = event.fire(self, *args)
        new_state = aasm.state_object_for_name(new_state_name)

        # new before_ callbacks
        old_state.fire_callbacks(:before_exit, self)
        new_state.fire_callbacks(:before_enter, self)

        new_state.fire_callbacks(:enter, self)

        persist_successful = true
        if persist
          persist_successful = aasm.set_current_state_with_persistence(new_state_name)
          event.fire_callbacks(:success, self) if persist_successful
        else
          aasm.current_state = new_state_name
        end

        if persist_successful
          old_state.fire_callbacks(:after_exit, self)
          new_state.fire_callbacks(:after_enter, self)
          event.fire_callbacks(:after, self)

          self.aasm_event_fired(name, old_state.name, aasm.current_state) if self.respond_to?(:aasm_event_fired)
        else
          self.aasm_event_failed(name, old_state.name) if self.respond_to?(:aasm_event_failed)
        end

        persist_successful

      else
        if self.respond_to?(:aasm_event_failed)
          self.aasm_event_failed(name, old_state.name)
        end

        if AASM::StateMachine[self.class].config.whiny_transitions
          raise AASM::InvalidTransition, "Event '#{event.name}' cannot transition from '#{aasm.current_state}'"
        else
          false
        end
      end
    rescue StandardError => e
      event.fire_callbacks(:error, self, e) || raise(e)
    end
  end
end
