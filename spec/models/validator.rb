require 'active_record'

class Validator < ActiveRecord::Base
  include AASM
  aasm :column => :status do
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
