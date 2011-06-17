class AASM::StateMachine
  def self.[](clazz)
    (@machines ||= {})[clazz.to_s]
  end
  
  def self.[]=(clazz, machine)
    (@machines ||= {})[clazz.to_s] = machine
  end
  
  attr_accessor :states, :events, :initial_state, :config
  attr_reader :name

  def initialize(name)
    @name = name
    @initial_state = nil
    @states = []
    @events = {}
    @config = OpenStruct.new
  end

  def clone
    klone = super
    klone.states = states.clone
    klone.events = events.clone
    klone
  end

  def create_state(name, options)
    @states << AASM::SupportingClasses::State.new(name, options) unless @states.include?(name)
  end
end
