class StateMachineWithFailedEvent
  include AASM

  aasm do
    state :init, :initial => true
    state :failed

    event :failed do
      transitions :from => :init, :to => :failed
    end
  end
end
