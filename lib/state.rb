module AASM
  module SupportingClasses
    class State
      attr_reader :name

      def initialize(name, opts={})
        @name, @opts = name, opts
      end

      def entering(record)
        enteract = @opts[:enter]
        record.send(:run_transition_action, enteract) if enteract
      end

      def entered(record)
        afteractions = @opts[:after]
        return unless afteractions
        Array(afteractions).each do |afteract|
          record.send(:run_transition_action, afteract)
        end
      end

      def exited(record)
        exitact  = @opts[:exit]
        record.send(:run_transition_action, exitact) if exitact
      end
    end
  end
end
