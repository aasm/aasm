module AASM
  module SupportingClasses
    class StateTransition
      attr_reader :from, :to, :opts

      def initialize(opts)
        @from, @to, @guard = opts[:from], opts[:to], opts[:guard]
        @opts = opts
      end

#       def guard(obj)
#         # TODO should probably not be using obj
#         @guard ? obj.send(:run_transition_action, @guard) : true
#       end

#       def perform(obj)
#         # TODO should probably not be using obj
#         return false unless guard(obj)
#         loopback = obj.current_state == to
#         # TODO Maybe State should be a factory?
#         # State[:open] => returns same instance of State.new(:open)
#         next_state = StateFactory[to]
#         old_state  = StateFactory[obj.current_state]
#         old_state = states[obj.current_state]

#         next_state.entering(obj) unless loopback

#         obj.update_attribute(obj.class.state_column, to.to_s)

#         next_state.entered(obj) unless loopback
#         old_state.exited(obj) unless loopback
#         true
#       end

      def ==(obj)
        @from == obj.from && @to == obj.to
      end
    end
  end
end
