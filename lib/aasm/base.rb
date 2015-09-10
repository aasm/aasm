module AASM
  class Base

    attr_reader :state_machine

    def initialize(klass, name, state_machine, options={}, &block)
      @klass = klass
      @name = name
      # @state_machine = @klass.aasm(@name).state_machine
      @state_machine = state_machine
      @state_machine.config.column ||= (options[:column] || default_column).to_sym
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

      # make sure to raise an error if no_direct_assignment is enabled
      # and attribute is directly assigned though
      @klass.class_eval %Q(
        def #{@state_machine.config.column}=(state_name)
          if self.class.aasm(:#{@name}).state_machine.config.no_direct_assignment
            raise AASM::NoDirectAssignmentError.new(
              'direct assignment of AASM column has been disabled (see AASM configuration for this class)'
            )
          else
            super
          end
        end
      )
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

      if @klass.instance_methods.include?("#{name}?")
        warn "#{@klass.name}: The state name #{name} is already used!"
      end

      @klass.class_eval <<-EORUBY, __FILE__, __LINE__ + 1
        def #{name}?
          aasm(:#{@name}).current_state == :#{name}
        end
      EORUBY

      unless @klass.const_defined?("STATE_#{name.upcase}")
        @klass.const_set("STATE_#{name.upcase}", name)
      end
    end

    # define an event
    def event(name, options={}, &block)
      @state_machine.add_event(name, options, &block)

      if @klass.instance_methods.include?("may_#{name}?".to_sym)
        warn "#{@klass.name}: The event name #{name} is already used!"
      end

      # an addition over standard aasm so that, before firing an event, you can ask
      # may_event? and get back a boolean that tells you whether the guard method
      # on the transition will let this happen.
      @klass.class_eval <<-EORUBY, __FILE__, __LINE__ + 1
        def may_#{name}?(*args)
          aasm(:#{@name}).may_fire_event?(:#{name}, *args)
        end

        def #{name}!(*args, &block)
          aasm(:#{@name}).current_event = :#{name}!
          aasm_fire_event(:#{@name}, :#{name}, {:persist => true}, *args, &block)
        end

        def #{name}(*args, &block)
          aasm(:#{@name}).current_event = :#{name}
          aasm_fire_event(:#{@name}, :#{name}, {:persist => false}, *args, &block)
        end
      EORUBY
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

    def default_column
      @name.to_sym == :default ? :aasm_state : @name.to_sym
    end

    def configure(key, default_value)
      if @options.key?(key)
        @state_machine.config.send("#{key}=", @options[key])
      elsif @state_machine.config.send(key).nil?
        @state_machine.config.send("#{key}=", default_value)
      end
    end

  end
end
