class Silencer
  include AASM

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
