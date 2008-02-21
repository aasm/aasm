require File.join(File.dirname(__FILE__), 'event')

module AASM
  class InvalidTransition < Exception
  end
  
  def self.included(base) #:nodoc:
    base.extend AASM::ClassMethods
  end

  module ClassMethods
    def aasm_initial_state
      @aasm_initial_state
    end
    
    def aasm_initial_state=(state)
      @aasm_initial_state = state
    end
    alias :initial_state :aasm_initial_state=
    
    def state(name, options={})
      self.aasm_initial_state = name unless self.aasm_initial_state

      define_method("#{name.to_s}?") do
        aasm_current_state == name
      end
    end
    
    def event(name, &block)
      aasm_events[name] = AASM::SupportingClasses::Event.new(name, &block)

      define_method("#{name.to_s}!") do
        new_state = self.class.aasm_events[name].fire(self)
        self.aasm_current_state = new_state
        nil
      end
    end

    def aasm_events
      @aasm_events ||= {}
    end
  end

  # Instance methods
  def aasm_current_state
    # Persistance?  This won't work for activerecord objects
    @aasm_current_state || self.class.aasm_initial_state
  end

  private
  def aasm_current_state=(state)
    @aasm_current_state = state
    if self.respond_to?(:aasm_persist) || self.private_methods.include?('aasm_persist')
      aasm_persist
    end
  end
end
