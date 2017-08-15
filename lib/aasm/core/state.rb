module AASM::Core
  class State
    attr_reader :name, :state_machine, :options

    def initialize(name, klass, state_machine, options={})
      @name = name
      @klass = klass
      @state_machine = state_machine
      update(options)
    end

    # called internally by Ruby 1.9 after clone()
    def initialize_copy(orig)
      super
      @options = {}
      orig.options.each_pair { |name, setting| @options[name] = setting.is_a?(Hash) || setting.is_a?(Array) ? setting.dup : setting }
    end

    def ==(state)
      if state.is_a? Symbol
        name == state
      else
        name == state.name
      end
    end

    def <=>(state)
      if state.is_a? Symbol
        name <=> state
      else
        name <=> state.name
      end
    end

    def to_s
      name.to_s
    end

    def fire_callbacks(action, record, *args)
      action = @options[action]
      catch :halt_aasm_chain do
        action.is_a?(Array) ?
                action.each {|a| _fire_callbacks(a, record, args)} :
                _fire_callbacks(action, record, args)
      end
    end

    def human_name
      @human_name ||= AASM::Localizer.new.human_state_name(@klass, self)
    end
    alias localized_name human_name
    alias display_name human_name
    # deprecate :display_name, :human_name

    def for_select
      [human_name, name.to_s]
    end

  private

    def update(options = {})
      @human_name = options.delete(:display) if options.key?(:display)
      @options = options
      self
    end

    def _fire_callbacks(action, record, args)
      case action
        when Symbol, String
          arity = record.__send__(:method, action.to_sym).arity
          record.__send__(action, *(arity < 0 ? args : args[0...arity]))
        when Proc
          arity = action.arity
          action.call(record, *(arity < 0 ? args : args[0...arity]))
      end
    end

  end
end # AASM
