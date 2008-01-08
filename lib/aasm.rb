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
      define_method("#{name.to_s}?") do
        aasm_current_state == name
      end
      self.aasm_initial_state = name unless self.aasm_initial_state
    end

    def event(name, &block)
      define_method("#{name.to_s}!") do
        new_state = self.class.events[name].fire(self)
        self.aasm_current_state = new_state
        nil
      end

      events[name] = AASM::SupportingClasses::Event.new(name, &block)
      # Error if event defines no transitions?
    end

    # TODO I don't much like exposing this
    def events
      @aasm_events ||= {}
    end
  end

  def aasm_current_state
    @aasm_current_state || self.class.aasm_initial_state
  end

  private
  def aasm_current_state=(state)
    @aasm_current_state = state
    if self.respond_to?(:aasm_after_update) || self.private_methods.include?('aasm_after_update')
      aasm_after_update
    end
  end
end
