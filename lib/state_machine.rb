require 'ostruct'

module AASM
  class StateMachine
    def self.[](*args)
      (@machines ||= {})[args]
    end

    def self.[]=(*args)
      val = args.pop
      (@machines ||= {})[args] = val
    end
    
    attr_accessor :states, :events, :initial_state, :config
    attr_reader :name
    
    def initialize(name)
      @name   = name
      @initial_state = nil
      @states = []
      @events = {}
      @config = OpenStruct.new
    end

    def create_state(name, options)
      @states << AASM::SupportingClasses::State.new(name, options) unless @states.include?(name)
    end
  end
end
