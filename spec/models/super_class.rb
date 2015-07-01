class SuperClass
  include AASM

  aasm do
    state :read
    state :ended

    event :foo do
      transitions :to => :ended, :from => [:read]
    end
  end

  def update_state
    if may_foo?
      foo!
    end
  end
end

class SuperClassMultiple
  include AASM

  aasm(:left) do
    state :read
    state :ended

    event :foo do
      transitions :to => :ended, :from => [:read]
    end
  end

  aasm(:right) do
    state :opened
    state :closed

    event :close do
      transitions :to => :closed, :from => [:opened]
    end
  end

  def update_state
    if may_foo?
      foo!
    end
  end
end
