require 'active_record'

class Validator < ActiveRecord::Base

  include AASM
  aasm :column => :status do
    state :sleeping, :initial => true
    state :running
    state :failed, :after_enter => :fail

    event :run, :after_commit => :change_name! do
      transitions :to => :running, :from => :sleeping
    end
    event :sleep do
      after_commit do |name|
        change_name_on_sleep name
      end
      transitions :to => :sleeping, :from => :running
    end
    event :fail do
      transitions :to => :failed, :from => [:sleeping, :running]
    end
  end

  validates_presence_of :name

  def change_name!
    self.name = "name changed"
    save!
  end

  def change_name_on_sleep name
    self.name = name
    save!
  end

  def fail
    raise StandardError.new('failed on purpose')
  end
end

class MultipleValidator < ActiveRecord::Base

  include AASM
  aasm :left, :column => :status do
    state :sleeping, :initial => true
    state :running
    state :failed, :after_enter => :fail

    event :run, :after_commit => :change_name! do
      transitions :to => :running, :from => :sleeping
    end
    event :sleep do
      after_commit do |name|
        change_name_on_sleep name
      end
      transitions :to => :sleeping, :from => :running
    end
    event :fail do
      transitions :to => :failed, :from => [:sleeping, :running]
    end
  end

  validates_presence_of :name

  def change_name!
    self.name = "name changed"
    save!
  end

  def change_name_on_sleep name
    self.name = name
    save!
  end

  def fail
    raise StandardError.new('failed on purpose')
  end
end
