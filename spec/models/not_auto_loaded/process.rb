module Models
  class Process
    include AASM

    aasm do
      state :sleeping
      state :running
      state :suspended

      event :start do
        transitions :from => :sleeping, :to => :running
      end

      event :stop do
        transitions :from => :running, :to => :suspended
      end
    end

  end
end

