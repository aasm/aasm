class SilentPersistorNoBrainer
  include NoBrainer::Document
  include AASM

  field :name
  field :status

  aasm :left, column: :status, whiny_persistence: false do
    state :sleeping, initial: true
    state :running
    event :run do
      transitions to: :running, from: :sleeping
    end
    event :sleep do
      transitions to: :sleeping, from: :running
    end
  end
  validates_presence_of :name
end

class MultipleSilentPersistorNoBrainer
  include NoBrainer::Document
  include AASM

  field :name
  field :status

  aasm :left, column: :status, whiny_persistence: false do
    state :sleeping, initial: true
    state :running
    event :run do
      transitions to: :running, from: :sleeping
    end
    event :sleep do
      transitions to: :sleeping, from: :running
    end
  end
  validates_presence_of :name
end
