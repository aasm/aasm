class InvalidPersistorMongoid
  include Mongoid::Document
  include AASM

  field :name
  field :status

  aasm :left, column: :status, skip_validation_on_save: true do
    state :sleeping, :initial => true
    state :running
    event :run do
      transitions :to => :running, :from => :sleeping
    end
    event :sleep do
      transitions :to => :sleeping, :from => :running
    end
  end
  validates_presence_of :name
end

class MultipleInvalidPersistorMongoid
  include Mongoid::Document
  include AASM

  field :name
  field :status

  aasm :left, column: :status, skip_validation_on_save: true do
    state :sleeping, :initial => true
    state :running
    event :run do
      transitions :to => :running, :from => :sleeping
    end
    event :sleep do
      transitions :to => :sleeping, :from => :running
    end
  end
  validates_presence_of :name
end
