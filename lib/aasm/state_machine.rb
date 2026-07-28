module AASM
  class StateMachine
    # the following four methods provide the storage of all state machines

    attr_accessor :states, :events, :initial_state, :config, :name, :implementation, :global_callbacks

    def initialize(name)
      @initial_state = nil
      @states = []
      @events = {}
      @global_callbacks = {}
      @config = AASM::Configuration.new
      @name = name
    end

    # called internally by Ruby 1.9 after clone()
    def initialize_copy(orig)
      super
      @states = orig.states.collect { |state| state.clone }
      @events = {}
      orig.events.each_pair { |name, event| @events[name] = event.clone }
      @global_callbacks = @global_callbacks.dup
    end

    def add_state(state_name, klass, options)
      set_initial_state(state_name, options)

      # allow reloading, extending or redefining a state
      @states.delete(state_name) if @states.include?(state_name)

      state_class = implementation.aasm_state_class
      raise ArgumentError, "The class #{state_class} must inherit from AASM::Core::State!" unless state_class.ancestors.include?(AASM::Core::State)
      @states << state_class.new(state_name, klass, self, options)
    end

    def add_event(name, options, &block)
      event_class = implementation.aasm_event_class
      raise ArgumentError, "The class #{event_class} must inherit from AASM::Core::Event!" unless event_class.ancestors.include?(AASM::Core::Event)
      @events[name] = event_class.new(name, self, options, &block)
    end

    def add_global_callbacks(name, *callbacks, &block)
      @global_callbacks[name] ||= []
      callbacks.each do |callback|
        @global_callbacks[name] << callback unless @global_callbacks[name].include? callback
      end
      @global_callbacks[name] << block if block
    end

    private

    def set_initial_state(name, options)
      @initial_state = name if options[:initial] || !initial_state
    end

  end # StateMachine
end # AASM
