class MultiTransitioner
  include AASM

  attr_accessor :can_run

  def initialize
    @can_run = false
  end

  aasm do
    state :sleeping, :initial => true
    state :running
    state :dancing
    state :dead

    event :start do
      transitions :from => :sleeping, :to => :running, guard: :runnable?
      transitions :from => :sleeping, :to => :dancing
    end

    event :sleep do
      transitions to: :sleeping, if: :alive?
      transitions to: :dead, from: [:running, :dancing]
    end
  end

  def runnable?
    @can_run
  end

  def alive?
    true
  end
end
