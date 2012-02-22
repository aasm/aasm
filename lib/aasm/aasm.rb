module AASM

  def self.included(base) #:nodoc:
    base.extend AASM::ClassMethods

    unless AASM::StateMachine[base]
      AASM::StateMachine[base] = AASM::StateMachine.new('')
    end
    AASM::Persistence.set_persistence(base)
   super
  end

  module ClassMethods
    def inherited(klass)
      AASM::StateMachine[klass] = AASM::StateMachine[self].clone
      super
    end

    def aasm(options={}, &block)
      @aasm ||= AASM::Base.new(self, options)
      @aasm.instance_eval(&block) if block
      @aasm
    end

    def aasm_initial_state(set_state=nil)
      if set_state
        # deprecated
        AASM::StateMachine[self].initial_state = set_state
      else
        AASM::StateMachine[self].initial_state
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

    def aasm_human_event_name(event)
      AASM::SupportingClasses::Localizer.new.human_event_name(self, event)
    end
  end

  # this method does what? does it deliver the current state?
  def aasm_current_state
    @aasm_current_state ||=
      aasm_persistable? ? aasm_read_state : aasm_enter_initial_state
  end

  # private?
  def aasm_enter_initial_state
    state_name = aasm_determine_state_name(self.class.aasm_initial_state)
    state = aasm_state_object_for_state(state_name)

    state.fire_callbacks(:before_enter, self)
    state.fire_callbacks(:enter, self)
    self.aasm_current_state = state_name
    state.fire_callbacks(:after_enter, self)

    state_name
  end

  # private?
  def aasm_events_for_current_state
    aasm_events_for_state(aasm_current_state)
  end

  # filters the results of events_for_current_state so that only those that
  # are really currently possible (given transition guards) are shown.
  def aasm_permissible_events_for_current_state
    aasm_events_for_current_state.select{ |e| self.send(("may_" + e.to_s + "?").to_sym) }
  end

  def aasm_events_for_state(state)
    events = self.class.aasm_events.values.select {|event| event.transitions_from_state?(state) }
    events.map {|event| event.name}
  end

  def aasm_human_state
    AASM::SupportingClasses::Localizer.new.human_state(self)
  end

private

  def aasm_persistable?
    self.respond_to?(:aasm_read_state) || self.private_methods.include?('aasm_read_state')
  end

  def aasm_set_current_state_with_persistence(state)
    save_success = true
    if self.respond_to?(:aasm_write_state) || self.private_methods.include?('aasm_write_state')
      save_success = aasm_write_state(state)
    end
    self.aasm_current_state = state if save_success

    save_success
  end

  def aasm_current_state=(state)
    if self.respond_to?(:aasm_write_state_without_persistence) || self.private_methods.include?('aasm_write_state_without_persistence')
      aasm_write_state_without_persistence(state)
    end
    @aasm_current_state = state
  end

  def aasm_determine_state_name(state)
    case state
      when Symbol, String
        state
      when Proc
        state.call(self)
      else
        raise NotImplementedError, "Unrecognized state-type given.  Expected Symbol, String, or Proc."
    end
  end

  def aasm_state_object_for_state(name)
    obj = self.class.aasm_states.find {|s| s == name}
    raise AASM::UndefinedState, "State :#{name} doesn't exist" if obj.nil?
    obj
  end

  def aasm_may_fire_event?(name, *args)
    event = self.class.aasm_events[name]
    event.may_fire?(self, *args)
  end

  def aasm_fire_event(name, options, *args)
    persist = options[:persist]

    event = self.class.aasm_events[name]
    begin
      old_state = aasm_state_object_for_state(aasm_current_state)


      old_state.fire_callbacks(:exit, self)

      # new event before callback
      event.fire_callbacks(:before, self)

      if new_state_name = event.fire(self, *args)
        new_state = aasm_state_object_for_state(new_state_name)

        # new before_ callbacks
        old_state.fire_callbacks(:before_exit, self)
        new_state.fire_callbacks(:before_enter, self)

        new_state.fire_callbacks(:enter, self)

        persist_successful = true
        if persist
          persist_successful = aasm_set_current_state_with_persistence(new_state_name)
          event.execute_success_callback(self) if persist_successful
        else
          self.aasm_current_state = new_state_name
        end

        if persist_successful
          old_state.fire_callbacks(:after_exit, self)
          new_state.fire_callbacks(:after_enter, self)
          event.fire_callbacks(:after, self)

          self.aasm_event_fired(name, old_state.name, self.aasm_current_state) if self.respond_to?(:aasm_event_fired)
        else
          self.aasm_event_failed(name, old_state.name) if self.respond_to?(:aasm_event_failed)
        end

        persist_successful

      else
        if self.respond_to?(:aasm_event_failed)
          self.aasm_event_failed(name, old_state.name)
        end

        if AASM::StateMachine[self.class].config.whiny_transitions
          raise AASM::InvalidTransition, "Event '#{event.name}' cannot transition from '#{self.aasm_current_state}'"
        else
          false
        end
      end
    rescue StandardError => e
      event.execute_error_callback(self, e)
    end
  end
end
