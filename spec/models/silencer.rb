class Silencer
  include AASM

  # yes, this line is here on purpose
  # by this, we test if overriding configuration options works if
  # the state machine is "re-opened"
  aasm :whiny_transitions => true

  aasm :whiny_transitions => false do
    state :silent, :initial => true
    state :crying
    state :smiling

    event :cry do
      transitions :from => :silent, :to => :crying
    end

    event :smile do
      transitions :from => :crying, :to => :smiling
    end

    event :smile_any do
      transitions :to => :smiling
    end
  end

end
