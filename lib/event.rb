require File.join(File.dirname(__FILE__), 'state_transition')

module AASM
  module SupportingClasses
    class Event
      attr_reader :name

      def initialize(name, &block)
        @name        = name.to_sym
        @transitions = []
        instance_eval(&block) if block
      end

      def next_states(from)
        @transitions.select { |t| t.from == from }
      end

      def fire(record)
        next_states(record).each do |transition|
          break true if transition.perform(record)
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
