class CustomAasmBase < AASM::Base

  def aasm_state_class
    CustomState
  end

  def aasm_event_class
    CustomEvent
  end

  def aasm_transition_class
    CustomTransition
  end
end
