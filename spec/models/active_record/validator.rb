class Validator < ActiveRecord::Base
  attr_accessor :after_all_transactions_performed,
    :after_transaction_performed_on_fail,
    :after_transaction_performed_on_run,
    :before_all_transactions_performed,
    :before_transaction_performed_on_fail,
    :before_transaction_performed_on_run,
    :invalid

  validate do |model|
    errors.add(:validator, "invalid") if invalid
  end

  include AASM

  aasm :column => :status, :whiny_persistence => true do
    before_all_transactions :before_all_transactions
    after_all_transactions  :after_all_transactions

    state :sleeping, :initial => true
    state :running
    state :failed, :after_enter => :fail

    event :run, :after_commit => :change_name! do
      after_transaction do
        @after_transaction_performed_on_run = true
      end

      before_transaction do
        @before_transaction_performed_on_run = true
      end

      transitions :to => :running, :from => :sleeping
    end

    event :sleep do
      after_commit do |name|
        change_name_on_sleep name
      end
      transitions :to => :sleeping, :from => :running
    end

    event :fail do
      after_transaction do
        @after_transaction_performed_on_fail = true
      end

      before_transaction do
        @before_transaction_performed_on_fail = true
      end

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

  def after_all_transactions
    @after_all_transactions_performed = true
  end

  def before_all_transactions
    @before_all_transactions_performed = true
  end
end

class MultipleValidator < ActiveRecord::Base

  include AASM
  aasm :left, :column => :status, :whiny_persistence => true do
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
