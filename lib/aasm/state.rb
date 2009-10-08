module AASM
  module SupportingClasses
    class State
      attr_reader :name, :options

      def initialize(name, options={})
        @name, @options = name, options
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
        if action.is_a? Array
          action.each do |a|
            _call(a, record)
          end
        else
          _call(action, record)
        end
      end

      def for_select
        [name.to_s.gsub(/_/, ' ').capitalize, name.to_s]
      end
      
      private
      def _call(action, record)
        case action
        when Symbol, String
          record.send(action)
        when Proc
          action.call(record)
        when Array
          action.each { |a| record.send(a) }
        end
      end
    end
  end
end
