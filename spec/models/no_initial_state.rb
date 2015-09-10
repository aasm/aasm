class NoInitialState
  include AASM

  aasm do
    state :read
    state :ended

    event :foo do
      transitions :to => :ended, :from => [:read]
    end
  end
end

class NoInitialStateMultiple
  include AASM

  aasm(:left) do
    state :read
    state :ended

    event :foo do
      transitions :to => :ended, :from => [:read]
    end
  end
end
