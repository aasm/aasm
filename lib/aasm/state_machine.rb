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
      @config = AASM::Configuration.new
    end

    # called internally by Ruby 1.9 after clone()
    def initialize_copy(orig)
      super
      @states = @states.dup
      @events = @events.dup
    end

    def add_state(name, klass, options)
      set_initial_state(name, options)

      if @states.include?(name)
        # Merge the new options to the existing state
        @states[@states.find_index(name)].merge options
      else
        @states << AASM::Core::State.new(name, klass, options)
      end
    end

    private

    def set_initial_state(name, options)
      @initial_state = name if options[:initial] || !initial_state
    end

  end # StateMachine
end # AASM
