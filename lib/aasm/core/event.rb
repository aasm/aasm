# frozen_string_literal: true

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
        :before_success,
        :success,
      ], &block) if block
    end

    # called internally by Ruby 1.9 after clone()
    def initialize_copy(orig)
      super
      @transitions = @transitions.collect { |transition| transition.clone }
      @guards      = @guards.dup
      @unless      = @unless.dup
      @options     = {}
      orig.options.each_pair { |name, setting| @options[name] = setting.is_a?(Hash) || setting.is_a?(Array) ? setting.dup : setting }
    end

    # a neutered version of fire - it doesn't actually fire the event, it just
    # executes the transition guards to determine if a transition is even
    # an option given current conditions.
    def may_fire?(obj, to_state=::AASM::NO_VALUE, *args)
      _fire(obj, {:test_only => true}, to_state, *args) # true indicates test firing
    end

    def fire(obj, options={}, to_state=::AASM::NO_VALUE, *args)
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
        if !definitions[:from] && definitions[:to]
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

    def _fire(obj, options={}, to_state=::AASM::NO_VALUE, *args)
      result = options[:test_only] ? false : nil
      clear_failed_callbacks
      transitions = @transitions.select { |t| t.from == obj.aasm(state_machine.name).current_state || t.from == nil}
      return result if transitions.size == 0

      if to_state == ::AASM::NO_VALUE
        to_state = nil
      elsif to_state.respond_to?(:to_sym) && transitions.map(&:to).flatten.include?(to_state.to_sym)
        # nop, to_state is a valid to-state
      else
        # to_state is an argument
        args.unshift(to_state)
        to_state = nil
      end

      transitions.each do |transition|
        next if to_state and !Array(transition.to).include?(to_state)
        if (options.key?(:may_fire) && transition.eql?(options[:may_fire])) ||
           (!options.key?(:may_fire) && transition.allowed?(obj, *args))

          if options[:test_only]
            result = transition
          else
            result = to_state || Array(transition.to).first
            Array(transition.to).each {|to| @valid_transitions[to] = transition }
            transition.execute(obj, *args)
          end

          break
        end
      end
      result
    end

    def clear_failed_callbacks
      # https://github.com/aasm/aasm/issues/383, https://github.com/aasm/aasm/issues/599
      transitions.each { |transition| transition.failures.clear }
    end

    def invoke_callbacks(code, record, args)
      Invoker.new(code, record, args)
             .with_default_return_value(false)
             .invoke
    end
  end
end # AASM
