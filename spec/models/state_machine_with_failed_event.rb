class StateMachineWithFailedEvent
  include AASM

  aasm do
    state :init, :initial => true
    state :failed
    state :sent

    event :failed do
      transitions :from => :init, :to => :failed
    end
    event :send, :before => :callback do
      transitions :from => :init, :to => :sent
    end
  end

  def callback
    true
  end
end
