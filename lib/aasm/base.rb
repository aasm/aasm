require 'logger'

module AASM
  class Base

    attr_reader :klass, :state_machine

    def initialize(klass, name, state_machine, options={}, &block)
      @klass = klass
      @name = name
      # @state_machine = klass.aasm(@name).state_machine
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

      # raise if the model is invalid (in ActiveRecord)
      configure :whiny_persistence, false

      # Use transactions (in ActiveRecord)
      configure :use_transactions, true

      # use requires_new for nested transactions (in ActiveRecord)
      configure :requires_new_transaction, true

      # use pessimistic locking (in ActiveRecord)
      # true for FOR UPDATE lock
      # string for a specific lock type i.e. FOR UPDATE NOWAIT
      configure :requires_lock, false

      # automatically set `"#{state_name}_at" = ::Time.now` on state changes
      configure :timestamps, false

      # set to true to forbid direct assignment of aasm_state column (in ActiveRecord)
      configure :no_direct_assignment, false

      # allow a AASM::Base sub-class to be used for state machine
      configure :with_klass, AASM::Base

      configure :enum, nil

      # Set to true to namespace reader methods and constants
      configure :namespace, false

      # Configure a logger, with default being a Logger to STDERR
      configure :logger, Logger.new(STDERR)

      # setup timestamp-setting callback if enabled
      setup_timestamps(@name)

      # make sure to raise an error if no_direct_assignment is enabled
      # and attribute is directly assigned though
      setup_no_direct_assignment(@name)
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
    # args
    # [0] state
    # [1] options (or nil)
    # or
    # [0] state
    # [1..] state
    def state(*args)
      names, options = interpret_state_args(args)
      names.each do |name|
        @state_machine.add_state(name, klass, options)

        aasm_name = @name.to_sym
        state = name.to_sym

        method_name = namespace? ? "#{namespace}_#{name}" : name
        safely_define_method klass, "#{method_name}?", -> do
          aasm(aasm_name).current_state == state
        end

        const_name = namespace? ? "STATE_#{namespace.upcase}_#{name.upcase}" : "STATE_#{name.upcase}"
        unless klass.const_defined?(const_name)
          klass.const_set(const_name, name)
        end
      end
    end

    # define an event
    def event(name, options={}, &block)
      @state_machine.add_event(name, options, &block)

      aasm_name = @name.to_sym
      event = name.to_sym

      # an addition over standard aasm so that, before firing an event, you can ask
      # may_event? and get back a boolean that tells you whether the guard method
      # on the transition will let this happen.
      safely_define_method klass, "may_#{name}?", ->(*args) do
        aasm(aasm_name).may_fire_event?(event, *args)
      end

      safely_define_method klass, "#{name}!", ->(*args, &block) do
        aasm(aasm_name).current_event = :"#{name}!"
        aasm_fire_event(aasm_name, event, {:persist => true}, *args, &block)
      end

      safely_define_method klass, name, ->(*args, &block) do
        aasm(aasm_name).current_event = event
        aasm_fire_event(aasm_name, event, {:persist => false}, *args, &block)
      end

      skip_instance_level_validation(event, name, aasm_name, klass)

      # Create aliases for the event methods. Keep the old names to maintain backwards compatibility.
      if namespace?
        klass.send(:alias_method, "may_#{name}_#{namespace}?", "may_#{name}?")
        klass.send(:alias_method, "#{name}_#{namespace}!", "#{name}!")
        klass.send(:alias_method, "#{name}_#{namespace}", name)
      end

    end

    def after_all_transitions(*callbacks, &block)
      @state_machine.add_global_callbacks(:after_all_transitions, *callbacks, &block)
    end

    def after_all_transactions(*callbacks, &block)
      @state_machine.add_global_callbacks(:after_all_transactions, *callbacks, &block)
    end

    def before_all_transactions(*callbacks, &block)
      @state_machine.add_global_callbacks(:before_all_transactions, *callbacks, &block)
    end

    def before_all_events(*callbacks, &block)
      @state_machine.add_global_callbacks(:before_all_events, *callbacks, &block)
    end

    def after_all_events(*callbacks, &block)
      @state_machine.add_global_callbacks(:after_all_events, *callbacks, &block)
    end

    def error_on_all_events(*callbacks, &block)
      @state_machine.add_global_callbacks(:error_on_all_events, *callbacks, &block)
    end

    def ensure_on_all_events(*callbacks, &block)
      @state_machine.add_global_callbacks(:ensure_on_all_events, *callbacks, &block)
    end

    def states
      @state_machine.states
    end

    def events
      @state_machine.events.values
    end

    # aasm.event(:event_name).human?
    def human_event_name(event) # event_name?
      AASM::Localizer.new.human_event_name(klass, event)
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

    def safely_define_method(klass, method_name, method_definition)
      # Warn if method exists and it did not originate from an enum
      if klass.method_defined?(method_name) &&
         ! ( @state_machine.config.enum &&
             klass.respond_to?(:defined_enums) &&
             klass.defined_enums.values.any?{ |methods|
                 methods.keys{| enum | enum + '?' == method_name }
             })
        unless AASM::Configuration.hide_warnings
          @state_machine.config.logger.warn "#{klass.name}: overriding method '#{method_name}'!"
        end
      end

      klass.send(:define_method, method_name, method_definition)
    end

    def namespace?
      !!@state_machine.config.namespace
    end

    def namespace
      if @state_machine.config.namespace == true
        @name
      else
        @state_machine.config.namespace
      end
    end

    def interpret_state_args(args)
      if args.last.is_a?(Hash) && args.size == 2
        [[args.first], args.last]
      elsif args.size > 0
        [args, {}]
      else
        raise "count not parse states: #{args}"
      end
    end

    def skip_instance_level_validation(event, name, aasm_name, klass)
      # Overrides the skip_validation config for an instance (If skip validation is set to false in original config) and
      # restores it back to the original value after the event is fired.
      safely_define_method klass, "#{name}_without_validation!", ->(*args, &block) do
        original_config = AASM::StateMachineStore.fetch(self.class, true).machine(aasm_name).config.skip_validation_on_save
        begin
          AASM::StateMachineStore.fetch(self.class, true).machine(aasm_name).config.skip_validation_on_save = true unless original_config
          aasm(aasm_name).current_event = :"#{name}!"
          aasm_fire_event(aasm_name, event, {:persist => true}, *args, &block)
        ensure
          AASM::StateMachineStore.fetch(self.class, true).machine(aasm_name).config.skip_validation_on_save = original_config
        end
      end
    end

    def setup_timestamps(aasm_name)
      return unless @state_machine.config.timestamps

      after_all_transitions do
        if self.class.aasm(:"#{aasm_name}").state_machine.config.timestamps
          ts_setter = "#{aasm(aasm_name).to_state}_at="
          respond_to?(ts_setter) && send(ts_setter, ::Time.now)
        end
      end
    end

    def setup_no_direct_assignment(aasm_name)
      return unless @state_machine.config.no_direct_assignment

      @klass.send(:define_method, "#{@state_machine.config.column}=") do |state_name|
        if self.class.aasm(:"#{aasm_name}").state_machine.config.no_direct_assignment
          raise AASM::NoDirectAssignmentError.new('direct assignment of AASM column has been disabled (see AASM configuration for this class)')
        else
          super(state_name)
        end
      end
    end

  end
end
