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

class NoLockTransactor < ActiveRecord::Base

  belongs_to :worker

  include AASM

  aasm :column => :status do
    state :sleeping, :initial => true
    state :running

    event :run do
      transitions :to => :running, :from => :sleeping
    end
  end
end

class LockTransactor < ActiveRecord::Base

  belongs_to :worker

  include AASM

  aasm :column => :status, requires_lock: true do
    state :sleeping, :initial => true
    state :running

    event :run do
      transitions :to => :running, :from => :sleeping
    end
  end
end

class LockNoWaitTransactor < ActiveRecord::Base

  belongs_to :worker

  include AASM

  aasm :column => :status, requires_lock: 'FOR UPDATE NOWAIT' do
    state :sleeping, :initial => true
    state :running

    event :run do
      transitions :to => :running, :from => :sleeping
    end
  end
end

class NoTransactor < ActiveRecord::Base

 belongs_to :worker

  include AASM
  aasm :column => :status, use_transactions: false do
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

class MultipleTransactor < ActiveRecord::Base

  belongs_to :worker

  include AASM
  aasm :left, :column => :status do
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
