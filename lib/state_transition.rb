module AASM
  module SupportingClasses
    class StateTransition
      attr_reader :from, :to, :opts

      def initialize(opts)
        @from, @to, @guard = opts[:from], opts[:to], opts[:guard]
        @opts = opts
      end

      def ==(obj)
        @from == obj.from && @to == obj.to
      end
    end
  end
end
