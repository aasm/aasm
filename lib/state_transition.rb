module AASM
  module SupportingClasses
    class StateTransition
      attr_reader :from, :to, :opts

      def initialize(opts)
        @from, @to, @guard = opts[:from], opts[:to], opts[:guard]
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
      
      def ==(obj)
        @from == obj.from && @to == obj.to
      end
    end
  end
end
