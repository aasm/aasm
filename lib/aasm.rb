require File.join(File.dirname(__FILE__), 'event')
require File.join(File.dirname(__FILE__), 'state')
require File.join(File.dirname(__FILE__), 'state_machine')
require File.join(File.dirname(__FILE__), 'persistence')

module AASM
  class InvalidTransition < Exception
  end
  
  def self.included(base) #:nodoc:
    base.extend AASM::ClassMethods
    AASM::Persistence.set_persistence(base)
    AASM::StateMachineFactory[base] = AASM::StateMachine.new('')
  end

  module ClassMethods
    def aasm_initial_state(set_state=nil)
      if set_state
        AASM::StateMachineFactory[self].initial_state = set_state
      else
        AASM::StateMachineFactory[self].initial_state
      end
    end
    
    def aasm_initial_state=(state)
      AASM::StateMachineFactory[self].initial_state = state
    end
    
    def aasm_state(name, options={})
      sm = AASM::StateMachineFactory[self]
      sm.create_state(name, options)
      sm.initial_state = name unless sm.initial_state

      define_method("#{name.to_s}?") do
        aasm_current_state == name
      end
    end
    
    def aasm_event(name, options = {}, &block)
      unless aasm_events.has_key?(name)
        aasm_events[name] = AASM::SupportingClasses::Event.new(name, options, &block)
      end

      define_method("#{name.to_s}!") do
        aasm_fire_event(name, true)
      end

      define_method("#{name.to_s}") do
        aasm_fire_event(name, false)
      end
    end

    def aasm_states
      AASM::StateMachineFactory[self].states
    end

    def aasm_events
      @aasm_events ||= {}
    end
    
    def aasm_states_for_select
      AASM::StateMachineFactory[self].states.map { |state| state.for_select }
    end
    
  end

  # Instance methods
  def aasm_current_state
    return @aasm_current_state if @aasm_current_state

    if self.respond_to?(:aasm_read_state) || self.private_methods.include?('aasm_read_state')
      @aasm_current_state = aasm_read_state
    end
    return @aasm_current_state if @aasm_current_state
    self.class.aasm_initial_state
  end

  def aasm_events_for_current_state
    aasm_events_for_state(aasm_current_state)
  end

  def aasm_events_for_state(state)
    events = self.class.aasm_events.values.select {|event| event.transitions_from_state?(state) }
    events.map {|event| event.name}
  end

  private
  def aasm_current_state_with_persistence=(state)
    if self.respond_to?(:aasm_write_state) || self.private_methods.include?('aasm_write_state')
      aasm_write_state(state)
    end
    self.aasm_current_state = state
  end

  def aasm_current_state=(state)
    if self.respond_to?(:aasm_write_state_without_persistence) || self.private_methods.include?('aasm_write_state_without_persistence')
      aasm_write_state_without_persistence(state)
    end
    @aasm_current_state = state
  end

  def aasm_state_object_for_state(name)
    AASM::StateMachineFactory[self.class].states.find {|s| s == name}
  end

  def aasm_fire_event(name, persist)
    aasm_state_object_for_state(aasm_current_state).call_action(:exit, self)

    new_state = self.class.aasm_events[name].fire(self)
    
    unless new_state.nil?
      aasm_state_object_for_state(new_state).call_action(:enter, self)
      
      if self.respond_to?(:aasm_event_fired)
        self.aasm_event_fired(self.aasm_current_state, new_state)
      end

      if persist
        self.aasm_current_state_with_persistence = new_state
        self.send(self.class.aasm_events[name].success) if self.class.aasm_events[name].success
      else
        self.aasm_current_state = new_state
      end

      true
    else
      if self.respond_to?(:aasm_event_failed)
        self.aasm_event_failed(name)
      end
      
      false
    end
  end
end
