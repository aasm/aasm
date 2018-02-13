class ValidatorNoBrainer
  include NoBrainer::Document
  include AASM

  field :name
  field :status

  attr_accessor :invalid

  validate do |_|
    errors.add(:validator, 'invalid') if invalid
  end

  aasm column: :status, whiny_persistence: true do
    before_all_transactions :before_all_transactions
    after_all_transactions  :after_all_transactions

    state :sleeping, initial: true
    state :running
    state :failed, after_enter: :fail

    event :run, after_commit: :change_name! do
      transitions to: :running, from: :sleeping
    end

    event :sleep do
      after_commit do |name|
        change_name_on_sleep name
      end
      transitions to: :sleeping, from: :running
    end

    event :fail do
      transitions to: :failed, from: %i[sleeping running]
    end
  end

  validates_presence_of :name

  def change_name!
    self.name = 'name changed'
    save!
  end

  def change_name_on_sleep(name)
    self.name = name
    save!
  end

  def fail
    raise StandardError, 'failed on purpose'
  end
end

class MultipleValidatorNoBrainer
  include NoBrainer::Document
  include AASM

  field :name
  field :status

  attr_accessor :invalid

  aasm :left, column: :status, whiny_persistence: true do
    state :sleeping, initial: true
    state :running
    state :failed, after_enter: :fail

    event :run, after_commit: :change_name! do
      transitions to: :running, from: :sleeping
    end
    event :sleep do
      after_commit do |name|
        change_name_on_sleep name
      end
      transitions to: :sleeping, from: :running
    end
    event :fail do
      transitions to: :failed, from: %i[sleeping running]
    end
  end

  validates_presence_of :name

  def change_name!
    self.name = 'name changed'
    save!
  end

  def change_name_on_sleep(name)
    self.name = name
    save!
  end

  def fail
    raise StandardError, 'failed on purpose'
  end
end
