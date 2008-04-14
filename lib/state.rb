module AASM
  module SupportingClasses
    class State
      attr_reader :name, :options

      def initialize(name, options={})
        @name, @options = name, options
      end

      def entering(record)
        enteract = @options[:enter]
        record.send(:run_transition_action, enteract) if enteract
      end

      def entered(record)
        afteractions = @options[:after]
        return unless afteractions
        Array(afteractions).each do |afteract|
          record.send(:run_transition_action, afteract)
        end
      end

      def exited(record)
        exitact  = @options[:exit]
        record.send(:run_transition_action, exitact) if exitact
      end
    end
  end
end
