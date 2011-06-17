module Models
  class Process
    include AASM

    aasm_state :sleeping
    aasm_state :running
    aasm_state :suspended

    aasm_event :start do
      transitions :from => :sleeping, :to => :running
    end

    aasm_event :stop do
      transitions :from => :running, :to => :suspended
    end

  end
end
