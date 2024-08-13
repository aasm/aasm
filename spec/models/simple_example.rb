class SimpleExample
  include AASM
  aasm do
    state :initialised, :initial => true
    state :filled_out
    state :denied
    state :authorised

    event :fill_out do
      transitions :from => :initialised, :to => :filled_out
    end

    event :deny do
      transitions from: :initialised, to: :denied
    end

    event :authorise do
      transitions :from => :filled_out, :to => :authorised
    end

  end

end
