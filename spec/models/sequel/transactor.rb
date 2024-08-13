db = Sequel::DATABASES.first || Sequel.connect(SEQUEL_DB)

[:transactors, :no_lock_transactors, :lock_transactors, :lock_no_wait_transactors, :multiple_transactors].each do |table_name|
  db.create_table(table_name) do
    primary_key :id
    String "name"
    String "status"
    Fixnum "worker_id"
  end
end

module Sequel
  class Transactor < Sequel::Model(:transactors)

    many_to_one :worker, class: 'Sequel::Worker'

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
      worker.update(status: 'running')
    end

    def fail
      raise StandardError.new('failed on purpose')
    end

  end

  class NoLockTransactor < Sequel::Model(:no_lock_transactors)

    many_to_one :worker, class: 'Sequel::Worker'

    include AASM

    aasm :column => :status do
      state :sleeping, :initial => true
      state :running

      event :run do
        transitions :to => :running, :from => :sleeping
      end
    end
  end

  class LockTransactor < Sequel::Model(:lock_transactors)

    many_to_one :worker, class: 'Sequel::Worker'

    include AASM

    aasm :column => :status, requires_lock: true do
      state :sleeping, :initial => true
      state :running

      event :run do
        transitions :to => :running, :from => :sleeping
      end
    end
  end

  class LockNoWaitTransactor < Sequel::Model(:lock_no_wait_transactors)

    many_to_one :worker, class: 'Sequel::Worker'

    include AASM

    aasm :column => :status, requires_lock: 'FOR UPDATE NOWAIT' do
      state :sleeping, :initial => true
      state :running

      event :run do
        transitions :to => :running, :from => :sleeping
      end
    end
  end

  class MultipleTransactor < Sequel::Model(:multiple_transactors)

    many_to_one :worker, class: 'Sequel::Worker'

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
      worker.update(:status, 'running')
    end

    def fail
      raise StandardError.new('failed on purpose')
    end

  end
end
