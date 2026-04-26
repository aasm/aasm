class NamespacedMultipleExample
  include AASM
  aasm(:status) do
    state :unapproved, :initial => true
    state :approved

    event :approve do
      transitions :from => :unapproved, :to => :approved
    end

    event :unapprove do
      transitions :from => :approved, :to => :unapproved
    end
  end

  aasm(:review_status, namespace: :review) do
    state :unapproved, :initial => true
    state :approved

    event :approve_review do
      transitions :from => :unapproved, :to => :approved
    end

    event :unapprove_review do
      transitions :from => :approved, :to => :unapproved
    end
  end

  # Test namespace event methods with suffix (ie may_sell_car?, sell_car!)
  aasm(:car, namespace: :car) do
    state :unsold, :initial => true
    state :sold

    event :sell do
      transitions :from => :unsold, :to => :sold
    end

    event :return do
      transitions :from => :sold, :to => :unsold
    end
  end
end
