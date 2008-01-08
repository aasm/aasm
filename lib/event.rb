require File.join(File.dirname(__FILE__), 'state_transition')

module AASM
  module SupportingClasses
    class Event
      attr_reader :name
      
      def initialize(name, &block)
        @name = name
        @transitions = []
        instance_eval(&block) if block
      end

      def fire(obj)
        transitions = @transitions.select { |t| t.from == obj.aasm_current_state }
        if transitions.size == 0
          raise AASM::InvalidTransition
        else
          transitions.first.to # Should be performing here - but what's involved
        end
      end

      private
      def transitions(trans_opts)
        Array(trans_opts[:from]).each do |s|
          @transitions << SupportingClasses::StateTransition.new(trans_opts.merge({:from => s.to_sym}))
        end
      end
    end
  end
end
