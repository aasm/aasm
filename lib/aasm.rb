module AASM
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
        current_state == name
      end
      self.aasm_initial_state = name unless self.aasm_initial_state
    end

    def event(name, options={}, &block)
      define_method("#{name.to_s}!") do
      end
    end
  end

  def current_state
    @aasm_current_state || self.class.aasm_initial_state
  end
end
