class MultipleTransitionsThatDifferOnlyByGuard
  include AASM

  attr_accessor :executed_second

  aasm do
    state :start, :initial => true
    state :gone

    event :go do
      transitions :from => :start, :to => :gone, :guard => :returns_false, :after => :this_should_not_execute
      transitions :from => :start, :to => :gone, :guard => :returns_true, :after => :this_should_execute
    end
  end

  def returns_false
    false
  end

  def returns_true
    true
  end

  def this_should_not_execute
    raise RuntimeError, "This should not execute"
  end

  def this_should_execute
    self.executed_second = true
  end
end