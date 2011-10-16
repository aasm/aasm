module AASM
  class Base
    def initialize(clazz, &block)
      @clazz = clazz
      instance_eval &block
    end
    
    def state(name, options={})
      @clazz.aasm_state(name, options)
    end

    def event(name, options={}, &block)
      @clazz.aasm_event(name, options, &block)
    end
  end
end
