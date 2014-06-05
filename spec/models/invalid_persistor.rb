require 'active_record'

class InvalidPersistor < ActiveRecord::Base
  include AASM::Methods
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
