module AASM
  module TransitionBuilder

  private

    def build_transition(definitions, from = nil, &block)
      transition_class = state_machine.implementation.aasm_transition_class
      raise ArgumentError, "The class #{transition_class} must inherit from AASM::Core::Transition!" unless transition_class.ancestors.include?(AASM::Core::Transition)

      definitions = definitions.merge(:from => from.to_sym) if from

      @transitions << transition_class.new(self, attach_event_guards(definitions), &block)
    end

    def attach_event_guards(definitions)
      unless @guards.empty?
        given_guards = Array(definitions.delete(:guard) || definitions.delete(:guards) || definitions.delete(:if))
        definitions[:guards] = @guards + given_guards # from aasm4
      end
      unless @unless.empty?
        given_unless = Array(definitions.delete(:unless))
        definitions[:unless] = given_unless + @unless
      end
      definitions
    end

  end
end
