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
        raise AASM::InvalidTransition if transitions.size == 0

        next_state = nil
        transitions.each do |transition|
          if transition.perform(obj)
            next_state = transition.to
            break
          end
        end
        next_state
      end

      def transitions_from_state?(state)
        @transitions.any? { |t| t.from == state }
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
