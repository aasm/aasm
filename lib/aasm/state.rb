module AASM
  module SupportingClasses
    class State
      attr_reader :name, :options

      def initialize(name, options={})
        @name = name
        update(options)
      end

      def ==(state)
        if state.is_a? Symbol
          name == state
        else
          name == state.name
        end
      end

      def call_action(action, record)
        action = @options[action]
        action.is_a?(Array) ?
                action.each {|a| _call_action(a, record)} :
                _call_action(action, record)
      end

      def display_name
        @display_name ||= name.to_s.gsub(/_/, ' ').capitalize
      end

      def for_select
        [display_name, name.to_s]
      end

      def update(options = {})
        if options.key?(:display) then
          @display_name = options.delete(:display)
        end
        @options = options
        self
      end

      private

      def _call_action(action, record)
        case action
          when Symbol, String
            record.send(action)
          when Proc
            action.call(record)
        end
      end

    end
  end
end
