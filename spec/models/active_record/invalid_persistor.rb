class InvalidPersistor < ActiveRecord::Base
  include AASM
  aasm :column => :status, :skip_validation_on_save => true do
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

class MultipleInvalidPersistor < ActiveRecord::Base
  include AASM
  aasm :left, :column => :status, :skip_validation_on_save => true do
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
