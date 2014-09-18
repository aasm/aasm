module AASM
  class Base

    def initialize(klass, options={}, &block)
      @klass = klass
      @state_machine = AASM::StateMachine[@klass]
      @state_machine.config.column = options[:column].to_sym if options[:column]
      @options = options

      # let's cry if the transition is invalid
      configure :whiny_transitions, true

      # create named scopes for each state
      configure :create_scopes, true

      # don't store any new state if the model is invalid
      configure :skip_validation_on_save, false

      # use requires_new for nested transactions
      configure :requires_new_transaction, true

      configure :enum, nil
    end

    def initial_state(new_initial_state=nil)
      if new_initial_state
        @state_machine.initial_state = new_initial_state
      else
        @state_machine.initial_state
      end
    end

    # define a state
    def state(name, options={})
      @state_machine.add_state(name, @klass, options)

      @klass.send(:define_method, "#{name.to_s}?") do
        aasm.current_state == name
      end

      unless @klass.const_defined?("STATE_#{name.to_s.upcase}")
        @klass.const_set("STATE_#{name.to_s.upcase}", name)
      end
    end

    # define an event
    def event(name, options={}, &block)
      @state_machine.events[name] = AASM::Event.new(name, options, &block)

      # an addition over standard aasm so that, before firing an event, you can ask
      # may_event? and get back a boolean that tells you whether the guard method
      # on the transition will let this happen.
      @klass.send(:define_method, "may_#{name.to_s}?") do |*args|
        aasm.may_fire_event?(name, *args)
      end

      @klass.send(:define_method, "#{name.to_s}!") do |*args, &block|
        aasm.current_event = "#{name.to_s}!".to_sym
        aasm_fire_event(name, {:persist => true}, *args, &block)
      end

      @klass.send(:define_method, "#{name.to_s}") do |*args, &block|
        aasm.current_event = name.to_sym
        aasm_fire_event(name, {:persist => false}, *args, &block)
      end
    end

    def states
      @state_machine.states
    end

    def events
      @state_machine.events
    end

    def states_for_select
      states.map { |state| state.for_select }
    end

    def from_states_for_state(state, options={})
      if options[:transition]
        events[options[:transition]].transitions_to_state(state).flatten.map(&:from).flatten
      else
        events.map {|k,v| v.transitions_to_state(state)}.flatten.map(&:from).flatten
      end
    end

    private

    def configure(key, default_value)
      @state_machine.config.send(:new_ostruct_member, key)
      if @options.key?(key)
        @state_machine.config.send("#{key}=", @options[key])
      elsif @state_machine.config.send(key).nil?
        @state_machine.config.send("#{key}=", default_value)
      end
    end

  end
end
