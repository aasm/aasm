require 'active_record'

class Validator < ActiveRecord::Base
  include AASM
  aasm :column => :status do
    state :sleeping, :initial => true
    state :awake
    state :running, :after_commit => :change_name!
    state :failed, :after_enter => :fail, :after_commit => :change_name!
    event :run do
      transitions :to => :running, :from => :sleeping
    end
    event :sleep do
      after_commit { append_name!(" slept") }
      transitions :to => :sleeping, :from => [:running, :awake]
    end
    event :wake do
      after_commit { append_name!(" awoke") }
      transitions :to => :awake, :from => :sleeping
    end
    event :fail do
      transitions :to => :failed, :from => [:sleeping, :running, :awake]
    end
  end
  validates_presence_of :name

  def change_name!
    self.name = "name changed"
    save!
  end

  def append_name!(suffix)
    self.name += suffix
    save!
  end

  def fail
    raise StandardError.new('failed on purpose')
  end
end
