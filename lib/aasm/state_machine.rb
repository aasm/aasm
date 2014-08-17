module AASM
  class StateMachine

    # the following two methods provide the storage of all state machines
    def self.[](klass)
      (@machines ||= {})[klass.to_s]
    end

    def self.[]=(klass, machine)
      (@machines ||= {})[klass.to_s] = machine
    end

    attr_accessor :states, :events, :initial_state, :config

    def initialize
      @initial_state = nil
      @states = []
      @events = {}
      @config = OpenStruct.new
    end

    # called internally by Ruby 1.9 after clone()
    def initialize_copy(orig)
      super
      @states = @states.dup
      @events = @events.dup
    end

    def add_state(name, klass, options)
      set_initial_state(name, options)

      # allow reloading, extending or redefining a state
      @states.delete(name) if @states.include?(name)

      @states << AASM::State.new(name, klass, options)
    end

    private

    def set_initial_state(name, options)
      @initial_state = name if options[:initial] || !initial_state
    end

  end # StateMachine
end # AASM
