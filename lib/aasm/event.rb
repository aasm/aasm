require File.join(File.dirname(__FILE__), 'state_transition')

module AASM
  module SupportingClasses
    class Event
      attr_reader :name, :success, :options
      
      def initialize(name, options = {}, &block)
        @name = name
        @success = options[:success]
        @transitions = []
        @options = options
        instance_eval(&block) if block
      end

      def fire(obj, to_state=nil, *args)
        transitions = @transitions.select { |t| t.from == obj.aasm_current_state }
        raise AASM::InvalidTransition, "Event '#{name}' cannot transition from '#{obj.aasm_current_state}'" if transitions.size == 0

        next_state = nil
        transitions.each do |transition|
          next if to_state and !Array(transition.to).include?(to_state)
          if transition.perform(obj)
            next_state = to_state || Array(transition.to).first
            transition.execute(obj, *args)
            break
          end
        end
        next_state
      end

      def transitions_from_state?(state)
        @transitions.any? { |t| t.from == state }
      end

      def transitions_from_state(state)
        @transitions.select { |t| t.from == state }
      end

      def execute_success_callback(obj, success = nil)
        callback = success || @success
        case(callback)
        when String, Symbol
          obj.send(callback)
        when Proc
          callback.call(obj)
        when Array
          callback.each{|meth|self.execute_success_callback(obj, meth)}
        end
      end

      def call_action(action, record)
        action = @options[action]
        case action
        when Symbol, String
          record.send(action)
        when Proc
          action.call(record)
        when Array
          action.each { |a| record.send(a) }
        end
      end

      def all_transitions
        @transitions
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
