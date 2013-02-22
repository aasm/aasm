module AASM
  class State
    attr_reader :name, :options

    def initialize(name, clazz, options={})
      @name = name
      @clazz = clazz
      update(options)
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

    def fire_callbacks(action, record)
      action = @options[action]
      catch :halt_aasm_chain do
        action.is_a?(Array) ?
                action.each {|a| _fire_callbacks(a, record)} :
                _fire_callbacks(action, record)
      end
    end

    def display_name
      @display_name ||= begin
        if Module.const_defined?(:I18n)
          localized_name
        else
          name.to_s.gsub(/_/, ' ').capitalize
        end
      end
    end

    def localized_name
      AASM::Localizer.new.human_state_name(@clazz, self)
    end

    def for_select
      [display_name, name.to_s]
    end

  private

    def update(options = {})
      if options.key?(:display) then
        @display_name = options.delete(:display)
      end
      @options = options
      self
    end

    def _fire_callbacks(action, record)
      case action
        when Symbol, String
          record.send(action)
        when Proc
          action.call(record)
      end
    end

  end
end # AASM
