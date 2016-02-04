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

    event :start do
      transitions :from => :sleeping, :to => :running, guard: :runnable?
      transitions :from => :sleeping, :to => :dancing
    end
  end

  def runnable?
    @can_run
  end
end
