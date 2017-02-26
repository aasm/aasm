class SimpleMultipleExample
  include AASM
  aasm(:move) do
    state :standing, :initial => true
    state :walking
    state :running

    event :walk do
      transitions :from => :standing, :to => :walking
    end
    event :run do
      transitions :from => [:standing, :walking], :to => :running
    end
    event :hold do
      transitions :from => [:walking, :running], :to => :standing
    end
  end

  aasm(:work) do
    state :sleeping, :initial => true
    state :processing

    event :start do
      transitions :from => :sleeping, :to => :processing
    end
    event :stop do
      transitions :from => :processing, :to => :sleeping
    end
  end

  aasm(:question) do
    state :answered, :initial => true
    state :asked

    event :ask, :binding_event => :start do
      transitions :from => :answered, :to => :asked
    end
    event :answer, :binding_event => :stop do
      transitions :from => :asked, :to => :answered
    end
  end
end
