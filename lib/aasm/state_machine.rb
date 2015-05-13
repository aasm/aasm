module AASM
  class StateMachine

    # the following two methods provide the storage of all state machines
    def self.[](klass)
      (@machines ||= {})[klass.to_s]
    end

    def self.[]=(klass, machine)
      (@machines ||= {})[klass.to_s] = machine
    end

    attr_accessor :states, :events, :initial_state, :config, :name

    def initialize(name)
      @initial_state = nil
      @states = []
      @events = {}
      @config = AASM::Configuration.new
      @name = name
    end

    # called internally by Ruby 1.9 after clone()
    def initialize_copy(orig)
      super
      @states = @states.dup
      @events = @events.dup
    end

    def add_state(state_name, klass, options)
      set_initial_state(state_name, options)

      # allow reloading, extending or redefining a state
      @states.delete(state_name) if @states.include?(state_name)

      @states << AASM::Core::State.new(state_name, klass, self, options)
    end

    def add_event(name, options, &block)
      @events[name] = AASM::Core::Event.new(name, self, options, &block)
    end

    private

    def set_initial_state(name, options)
      @initial_state = name if options[:initial] || !initial_state
    end

  end # StateMachine
end # AASM
