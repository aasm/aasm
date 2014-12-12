module AASM

  # provide a state machine for the including class
  # make sure to load class methods as well
  # initialize persistence for the state machine
  def self.included(base) #:nodoc:
    base.extend AASM::ClassMethods

    # do not overwrite existing state machines, which could have been created by
    # inheritance, see class method inherited
    AASM::StateMachine[base] ||= AASM::StateMachine.new

    AASM::Persistence.load_persistence(base)
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

    # deprecated, remove in version 4.1
    def aasm_human_event_name(event) # event_name?
      warn '[DEPRECATION] AASM: aasm_human_event_name is deprecated, use aasm.human_event_name instead'
      aasm.human_event_name(event)
    end
  end # ClassMethods

  def aasm
    @aasm ||= AASM::InstanceBase.new(self)
  end

private

  # Takes args and a from state and removes the first
  # element from args if it is a valid to_state for
  # the event given the from_state
  def process_args(event, from_state, *args)
    # If the first arg doesn't respond to to_sym then
    # it isn't a symbol or string so it can't be a state
    # name anyway
    return args unless args.first.respond_to?(:to_sym)
    if event.transitions_from_state(from_state).map(&:to).flatten.include?(args.first)
      return args[1..-1]
    end
    return args
  end

  def aasm_fire_event(event_name, options, *args, &block)
    event = self.class.aasm.state_machine.events[event_name]
    begin
      old_state = aasm.state_object_for_name(aasm.current_state)

      # new event before callback
      event.fire_callbacks(
        :before,
        self,
        *process_args(event, aasm.current_state, *args)
      )

      if may_fire_to = event.may_fire?(self, *args)
        old_state.fire_callbacks(:before_exit, self)
        old_state.fire_callbacks(:exit, self) # TODO: remove for AASM 4?

        if new_state_name = event.fire(self, {:may_fire => may_fire_to}, *args)
          aasm_fired(event, old_state, new_state_name, options, *args, &block)
        else
          aasm_failed(event_name, old_state)
        end
      else
        aasm_failed(event_name, old_state)
      end
    rescue StandardError => e
      event.fire_callbacks(:error, self, e, *process_args(event, aasm.current_state, *args)) || raise(e)
    end
  end

  def aasm_fired(event, old_state, new_state_name, options, *args)
    persist = options[:persist]

    new_state = aasm.state_object_for_name(new_state_name)

    new_state.fire_callbacks(:before_enter, self)

    new_state.fire_callbacks(:enter, self) # TODO: remove for AASM 4?

    persist_successful = true
    if persist
      persist_successful = aasm.set_current_state_with_persistence(new_state_name)
      if persist_successful
        yield if block_given?
        event.fire_callbacks(:success, self)
      end
    else
      aasm.current_state = new_state_name
      yield if block_given?
    end

    if persist_successful
      old_state.fire_callbacks(:after_exit, self)
      new_state.fire_callbacks(:after_enter, self)
      event.fire_callbacks(
        :after,
        self,
        *process_args(event, old_state.name, *args)
      )

      self.aasm_event_fired(event.name, old_state.name, aasm.current_state) if self.respond_to?(:aasm_event_fired)
    else
      self.aasm_event_failed(event.name, old_state.name) if self.respond_to?(:aasm_event_failed)
    end

    persist_successful
  end

  def aasm_failed(event_name, old_state)
    if self.respond_to?(:aasm_event_failed)
      self.aasm_event_failed(event_name, old_state.name)
    end

    if AASM::StateMachine[self.class].config.whiny_transitions
      raise AASM::InvalidTransition, "Event '#{event_name}' cannot transition from '#{aasm.current_state}'"
    else
      false
    end
  end

end
