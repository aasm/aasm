class ValidTransitionsExample
  include AASM

  aasm do
    state :pending, :initial => true
    state :running
    state :failed

    event :run, :success => :event_succeeded do
      transitions :from => :pending, :to => :running, :success => :transition_succeeded
    end

    event :crash do
      transitions :from => :pending, :to => :failed, :after => :explode
    end
  end

  def event_succeeded; end
  def transition_succeeded; end

  def explode
    raise ArgumentError, 'boom'
  end
end
