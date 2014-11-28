module AASM
  class Base

    attr_reader :state_machine

    def initialize(klass, options={}, &block)
      @klass = klass
      @state_machine = AASM::StateMachine[@klass]
      @state_machine.config.column ||= (options[:column] || :aasm_state).to_sym # aasm4
      # @state_machine.config.column = options[:column].to_sym if options[:column] # master
      @options = options

      # let's cry if the transition is invalid
      configure :whiny_transitions, true

      # create named scopes for each state
      configure :create_scopes, true

      # don't store any new state if the model is invalid (in ActiveRecord)
      configure :skip_validation_on_save, false

      # use requires_new for nested transactions (in ActiveRecord)
      configure :requires_new_transaction, true

      # set to true to forbid direct assignment of aasm_state column (in ActiveRecord)
      configure :no_direct_assignment, false

      configure :enum, nil

      if @state_machine.config.no_direct_assignment
        @klass.send(:define_method, "#{@state_machine.config.column}=") do |state_name|
          raise AASM::NoDirectAssignmentError.new('direct assignment of AASM column has been disabled (see AASM configuration for this class)')
        end
      end
    end

    # This method is both a getter and a setter
    def attribute_name(column_name=nil)
      if column_name
        @state_machine.config.column = column_name.to_sym
      else
        @state_machine.config.column ||= :aasm_state
      end
      @state_machine.config.column
    end

    def initial_state(new_initial_state=nil)
      if new_initial_state
        @state_machine.initial_state = new_initial_state
      else
        @state_machine.initial_state
      end
    end

    # define a state
    def state(name, options={})
      @state_machine.add_state(name, @klass, options)

      @klass.send(:define_method, "#{name.to_s}?") do
        aasm.current_state == name
      end

      unless @klass.const_defined?("STATE_#{name.to_s.upcase}")
        @klass.const_set("STATE_#{name.to_s.upcase}", name)
      end
    end

    # define an event
    def event(name, options={}, &block)
      @state_machine.events[name] = AASM::Core::Event.new(name, options, &block)

      # an addition over standard aasm so that, before firing an event, you can ask
      # may_event? and get back a boolean that tells you whether the guard method
      # on the transition will let this happen.
      @klass.send(:define_method, "may_#{name.to_s}?") do |*args|
        aasm.may_fire_event?(name, *args)
      end

      @klass.send(:define_method, "#{name.to_s}!") do |*args, &block|
        aasm.current_event = "#{name.to_s}!".to_sym
        aasm_fire_event(name, {:persist => true}, *args, &block)
      end

      @klass.send(:define_method, "#{name.to_s}") do |*args, &block|
        aasm.current_event = name.to_sym
        aasm_fire_event(name, {:persist => false}, *args, &block)
      end
    end

    def states
      @state_machine.states
    end

    def events
      @state_machine.events.values
    end

    # aasm.event(:event_name).human?
    def human_event_name(event) # event_name?
      AASM::Localizer.new.human_event_name(@klass, event)
    end

    def states_for_select
      states.map { |state| state.for_select }
    end

    def from_states_for_state(state, options={})
      if options[:transition]
        @state_machine.events[options[:transition]].transitions_to_state(state).flatten.map(&:from).flatten
      else
        events.map {|e| e.transitions_to_state(state)}.flatten.map(&:from).flatten
      end
    end

    private

    def configure(key, default_value)
      if @options.key?(key)
        @state_machine.config.send("#{key}=", @options[key])
      elsif @state_machine.config.send(key).nil?
        @state_machine.config.send("#{key}=", default_value)
      end
    end

  end
end
