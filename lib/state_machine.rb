module AASM
  unless AASM.const_defined?('StateMachineFactory')
    StateMachineFactory = {}
  end
  
  class StateMachine
    attr_accessor :states, :events, :initial_state
    attr_reader :name
    
    def initialize(name)
      @name   = name
      @initial_state = nil
      @states = []
      @events = []
    end

    def create_state(name, options)
      @states << AASM::SupportingClasses::State.new(name, options) unless @states.include?(name)
    end
  end
end
