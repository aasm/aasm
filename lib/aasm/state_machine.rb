module AASM
  class StateMachine

    # the following two methods provide the storage of all state machines
    def self.[](clazz)
      (@machines ||= {})[clazz.to_s]
    end

    def self.[]=(clazz, machine)
      (@machines ||= {})[clazz.to_s] = machine
    end

    attr_accessor :states, :events, :initial_state, :config
    attr_reader :name

    # QUESTION: what's the name for? [alto, 2012-11-28]
    def initialize(name)
      @name = name
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

    def add_state(name, clazz, options)
      @states << AASM::State.new(name, clazz, options) unless @states.include?(name)
    end

  end # StateMachine
end # AASM
