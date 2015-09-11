module AASM

  # provide a state machine for the including class
  # make sure to load class methods as well
  # initialize persistence for the state machine
  def self.included(base) #:nodoc:
    base.extend AASM::ClassMethods

    # do not overwrite existing state machines, which could have been created by
    # inheritance, see class method inherited
    AASM::StateMachine[base] ||= {}

    AASM::Persistence.load_persistence(base)
    super
  end

  module ClassMethods
    # make sure inheritance (aka subclassing) works with AASM
    def inherited(base)
      AASM::StateMachine[base] = {}
      AASM::StateMachine[self].keys.each do |state_machine_name|
        AASM::StateMachine[base][state_machine_name] = AASM::StateMachine[self][state_machine_name].clone
      end
      super
    end

    # this is the entry point for all state and event definitions
    def aasm(*args, &block)
      if args[0].is_a?(Symbol) || args[0].is_a?(String)
        # using custom name
        state_machine_name = args[0].to_sym
        options = args[1] || {}
      else
        # using the default state_machine_name
        state_machine_name = :default
        options = args[0] || {}
      end

      AASM::StateMachine[self][state_machine_name] ||= AASM::StateMachine.new(state_machine_name)

      @aasm ||= {}
      @aasm[state_machine_name] ||= AASM::Base.new(self, state_machine_name, AASM::StateMachine[self][state_machine_name], options)
      @aasm[state_machine_name].instance_eval(&block) if block # new DSL
      @aasm[state_machine_name]
    end
  end # ClassMethods

  # this is the entry point for all instance-level access to AASM
  def aasm(name=:default)
    unless AASM::StateMachine[self.class][name.to_sym]
      raise AASM::UnknownStateMachineError.new("There is no state machine with the name '#{name}' defined in #{self.class.name}!")
    end
    @aasm ||= {}
    @aasm[name.to_sym] ||= AASM::InstanceBase.new(self, name.to_sym)
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

  def aasm_fire_event(state_machine_name, event_name, options, *args, &block)
    event = self.class.aasm(state_machine_name).state_machine.events[event_name]
    begin
      old_state = aasm(state_machine_name).state_object_for_name(aasm(state_machine_name).current_state)

      # new event before callback
      event.fire_callbacks(
        :before,
        self,
        *process_args(event, aasm(state_machine_name).current_state, *args)
      )

      if may_fire_to = event.may_fire?(self, *args)
        old_state.fire_callbacks(:before_exit, self,
          *process_args(event, aasm(state_machine_name).current_state, *args))
        old_state.fire_callbacks(:exit, self,
          *process_args(event, aasm(state_machine_name).current_state, *args))

        if new_state_name = event.fire(self, {:may_fire => may_fire_to}, *args)
          aasm_fired(state_machine_name, event, old_state, new_state_name, options, *args, &block)
        else
          aasm_failed(state_machine_name, event_name, old_state)
        end
      else
        aasm_failed(state_machine_name, event_name, old_state)
      end
    rescue StandardError => e
      event.fire_callbacks(:error, self, e, *process_args(event, aasm(state_machine_name).current_state, *args)) || raise(e)
    end
  end

  def aasm_fired(state_machine_name, event, old_state, new_state_name, options, *args)
    persist = options[:persist]

    new_state = aasm(state_machine_name).state_object_for_name(new_state_name)

    new_state.fire_callbacks(:before_enter, self,
      *process_args(event, aasm(state_machine_name).current_state, *args))

    new_state.fire_callbacks(:enter, self,
      *process_args(event, aasm(state_machine_name).current_state, *args)) # TODO: remove for AASM 4?

    persist_successful = true
    if persist
      persist_successful = aasm(state_machine_name).set_current_state_with_persistence(new_state_name)
      if persist_successful
        yield if block_given?
        event.fire_callbacks(:success, self)
      end
    else
      aasm(state_machine_name).current_state = new_state_name
      yield if block_given?
    end

    if persist_successful
      old_state.fire_callbacks(:after_exit, self,
        *process_args(event, aasm(state_machine_name).current_state, *args))
      new_state.fire_callbacks(:after_enter, self,
        *process_args(event, aasm(state_machine_name).current_state, *args))
      event.fire_callbacks(
        :after,
        self,
        *process_args(event, old_state.name, *args)
      )

      self.aasm_event_fired(event.name, old_state.name, aasm(state_machine_name).current_state) if self.respond_to?(:aasm_event_fired)
    else
      self.aasm_event_failed(event.name, old_state.name) if self.respond_to?(:aasm_event_failed)
    end

    persist_successful
  end

  def aasm_failed(state_machine_name, event_name, old_state)
    if self.respond_to?(:aasm_event_failed)
      self.aasm_event_failed(event_name, old_state.name)
    end

    if AASM::StateMachine[self.class][state_machine_name].config.whiny_transitions
      raise AASM::InvalidTransition.new(self, event_name, state_machine_name)
    else
      false
    end
  end

end
