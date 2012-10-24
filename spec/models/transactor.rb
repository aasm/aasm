require 'active_record'
class Transactor < ActiveRecord::Base

  belongs_to :worker

  include AASM
  aasm :column => :status do
    state :sleeping, :initial => true
    state :running, :before_enter => :start_worker, :after_enter => :fail

    event :run do
      transitions :to => :running, :from => :sleeping
    end
  end

private

  def start_worker
    worker.update_attribute(:status, 'running')
  end

  def fail
    raise StandardError.new('failed on purpose')
  end

end
