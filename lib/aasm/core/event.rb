module AASM::Core
  class Event
    include DslHelper

    attr_reader :name, :state_machine, :options

    def initialize(name, state_machine, options = {}, &block)
      @name = name
      @state_machine = state_machine
      @transitions = []
      @valid_transitions = {}
      @guards = Array(options[:guard] || options[:guards] || options[:if])
      @unless = Array(options[:unless]) #TODO: This could use a better name

      # from aasm4
      @options = options # QUESTION: .dup ?
      add_options_from_dsl(@options, [
        :after,
        :after_commit,
        :after_transaction,
        :before,
        :before_transaction,
        :ensure,
        :error,
        :success,
      ], &block) if block
    end

    # a neutered version of fire - it doesn't actually fire the event, it just
    # executes the transition guards to determine if a transition is even
    # an option given current conditions.
    def may_fire?(obj, to_state=nil, *args)
      _fire(obj, {:test_only => true}, to_state, *args) # true indicates test firing
    end

    def fire(obj, options={}, to_state=nil, *args)
      _fire(obj, options, to_state, *args) # false indicates this is not a test (fire!)
    end

    def transitions_from_state?(state)
      transitions_from_state(state).any?
    end

    def transitions_from_state(state)
      @transitions.select { |t| t.from.nil? or t.from == state }
    end

    def transitions_to_state?(state)
      transitions_to_state(state).any?
    end

    def transitions_to_state(state)
      @transitions.select { |t| t.to == state }
    end

    def fire_global_callbacks(callback_name, record, *args)
      invoke_callbacks(state_machine.global_callbacks[callback_name], record, args)
    end

    def fire_callbacks(callback_name, record, *args)
      # strip out the first element in args if it's a valid to_state
      # #given where we're coming from, this condition implies args not empty
      invoke_callbacks(@options[callback_name], record, args)
    end

    def fire_transition_callbacks(obj, *args)
      from_state = obj.aasm(state_machine.name).current_state
      transition = @valid_transitions[from_state]
      @valid_transitions[from_state].invoke_success_callbacks(obj, *args) if transition
    end

    def ==(event)
      if event.is_a? Symbol
        name == event
      else
        name == event.name
      end
    end

    ## DSL interface
    def transitions(definitions=nil, &block)
      if definitions # define new transitions
        # Create a separate transition for each from-state to the given state
        Array(definitions[:from]).each do |s|
          @transitions << AASM::Core::Transition.new(self, attach_event_guards(definitions.merge(:from => s.to_sym)), &block)
        end
        # Create a transition if :to is specified without :from (transitions from ANY state)
        if @transitions.empty? && definitions[:to]
          @transitions << AASM::Core::Transition.new(self, attach_event_guards(definitions), &block)
        end
      end
      @transitions
    end

    def failed_callbacks
      transitions.flat_map(&:failures)
    end

  private

    def attach_event_guards(definitions)
      unless @guards.empty?
        given_guards = Array(definitions.delete(:guard) || definitions.delete(:guards) || definitions.delete(:if))
        definitions[:guards] = @guards + given_guards # from aasm4
      end
      unless @unless.empty?
        given_unless = Array(definitions.delete(:unless))
        definitions[:unless] = given_unless + @unless
      end
      definitions
    end

    def _fire(obj, options={}, to_state=nil, *args)
      result = options[:test_only] ? false : nil
      if @transitions.map(&:from).any?
        transitions = @transitions.select { |t| t.from == obj.aasm(state_machine.name).current_state }
        return result if transitions.size == 0
      else
        transitions = @transitions
      end

      # If to_state is not nil it either contains a potential
      # to_state or an arg
      unless to_state == nil
        if !to_state.respond_to?(:to_sym) || !transitions.map(&:to).flatten.include?(to_state.to_sym)
          args.unshift(to_state)
          to_state = nil
        end
      end

      transitions.each do |transition|
        next if to_state and !Array(transition.to).include?(to_state)
        if (options.key?(:may_fire) && Array(transition.to).include?(options[:may_fire])) ||
           (!options.key?(:may_fire) && transition.allowed?(obj, *args))
          result = to_state || Array(transition.to).first
          if options[:test_only]
            # result = true
          else
            Array(transition.to).each {|to| @valid_transitions[to] = transition }
            transition.execute(obj, *args)
          end

          break
        end
      end
      result
    end

    def invoke_callbacks(code, record, args)
      case code
        when Symbol, String
          unless record.respond_to?(code, true)
            raise NoMethodError.new("NoMethodError: undefined method `#{code}' for #{record.inspect}:#{record.class}")
          end
          arity = record.__send__(:method, code.to_sym).arity
          record.__send__(code, *(arity < 0 ? args : args[0...arity]))
          true

        when Proc
          arity = code.arity
          record.instance_exec(*(arity < 0 ? args : args[0...arity]), &code)
          true

        when Array
          code.each {|a| invoke_callbacks(a, record, args)}
          true

        else
          false
      end
    end
  end
end # AASM
