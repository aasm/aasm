module AASM
  class Base

    def initialize(clazz, options={}, &block)
      @clazz = clazz
      sm = AASM::StateMachine[@clazz]
      sm.config.column = options[:column].to_sym if options[:column]

      if options.key?(:whiny_transitions)
        sm.config.whiny_transitions = options[:whiny_transitions]
      elsif sm.config.whiny_transitions.nil?
        sm.config.whiny_transitions = true # this is the default, so let's cry
      end

      if options.key?(:skip_validation_on_save)
        sm.config.skip_validation_on_save = options[:skip_validation_on_save]
      elsif sm.config.skip_validation_on_save.nil?
        sm.config.skip_validation_on_save = false # this is the default, so don't store any new state if the model is invalid
      end
    end

    def initial_state
      AASM::StateMachine[@clazz].initial_state
    end

    def state(name, options={})
      # @clazz.aasm_state(name, options)
      sm = AASM::StateMachine[@clazz]
      sm.create_state(name, @clazz, options)
      sm.initial_state = name if options[:initial] || !sm.initial_state

      @clazz.send(:define_method, "#{name.to_s}?") do
        aasm_current_state == name
      end
    end

    def event(name, options={}, &block)
      # @clazz.aasm_event(name, options, &block)
      sm = AASM::StateMachine[@clazz]

      unless sm.events.has_key?(name)
        sm.events[name] = AASM::SupportingClasses::Event.new(name, options, &block)
      end

      # an addition over standard aasm so that, before firing an event, you can ask
      # may_event? and get back a boolean that tells you whether the guard method
      # on the transition will let this happen.
      @clazz.send(:define_method, "may_#{name.to_s}?") do |*args|
        aasm_may_fire_event?(name, *args)
      end

      @clazz.send(:define_method, "#{name.to_s}!") do |*args|
        aasm_fire_event(name, {:persist => true}, *args)
      end

      @clazz.send(:define_method, "#{name.to_s}") do |*args|
        aasm_fire_event(name, {:persist => false}, *args)
      end
    end

    def states
      AASM::StateMachine[@clazz].states
    end

    def events
      AASM::StateMachine[@clazz].events
    end

    def states_for_select
      states.map { |state| state.for_select }
    end

  end
end
