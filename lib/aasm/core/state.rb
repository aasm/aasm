module AASM::Core
  class State
    attr_reader :name, :options

    def initialize(name, klass, options={})
      @name = name
      @klass = klass
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

    # This merge will append new callbacks from the options to the state
    # if the state already have a after_enter and the options contains a after_enter callback
    # the state will have the list of callbacks to execute
    def merge(options={})
      @display_name = options.delete(:display_name) if options.key? :display_name

      options.each do |action, callback|
        if @options.has_key?(action)
          existing_callbacks = @options[action]
          existing_callbacks = [existing_callbacks] unless existing_callbacks.is_a?(Array)
          @options[action] = (existing_callbacks << callback).flatten
        else
          @options[action] = callback
        end
      end
      self
    end

    def fire_callbacks(action, record, *args)
      action = @options[action]
      catch :halt_aasm_chain do
        action.is_a?(Array) ?
                action.each {|a| _fire_callbacks(a, record, args)} :
                _fire_callbacks(action, record, args)
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
      AASM::Localizer.new.human_state_name(@klass, self)
    end
    alias human_name localized_name

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

    def _fire_callbacks(action, record, args)
      case action
        when Symbol, String
          arity = record.send(:method, action.to_sym).arity
          record.send(action, *(arity < 0 ? args : args[0...arity]))
        when Proc
          arity = action.arity
          action.call(record, *(arity < 0 ? args : args[0...arity]))
      end
    end

  end
end # AASM
