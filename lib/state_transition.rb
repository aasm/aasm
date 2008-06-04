module AASM
  module SupportingClasses
    class StateTransition
      attr_reader :from, :to, :opts

      def initialize(opts)
        @from, @to, @guard, @on_transition = opts[:from], opts[:to], opts[:guard], opts[:on_transition]
        @opts = opts
      end

      def perform(obj)
        case @guard
        when Symbol, String
          obj.send(@guard)
        when Proc
          @guard.call(obj)
        else
          true
        end
      end
      
      def execute(obj, *args)
        case @on_transition
        when Symbol, String
          obj.send(@on_transition, *args)
        when Proc
          @on_transition.call(obj, *args)
        end
      end

      def ==(obj)
        @from == obj.from && @to == obj.to
      end
    end
  end
end
