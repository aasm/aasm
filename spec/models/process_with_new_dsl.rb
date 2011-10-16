class ProcessWithNewDsl
  include AASM

  def self.state(*args)
    raise "wrong state method"
  end

  aasm do
    state :sleeping, :initial => true
    state :running
    state :suspended

    event :start do
      transitions :from => :sleeping, :to => :running
    end
    event :stop do
      transitions :from => :running, :to => :suspended
    end
  end

  def self.event(*args)
    raise "wrong event method"
  end

end
