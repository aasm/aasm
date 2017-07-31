db = Sequel::DATABASES.first || Sequel.connect(SEQUEL_DB)

db.create_table(:validators) do
  primary_key :id
  String "name"
  String "status"
  Fixnum "worker_id"
end

module Sequel
  class Validator < Sequel::Model(:validators)
    plugin :validation_helpers

    attr_accessor :after_all_transactions_performed,
      :after_transaction_performed_on_fail,
      :after_transaction_performed_on_run,
      :before_all_transactions_performed,
      :before_transaction_performed_on_fail,
      :before_transaction_performed_on_run,
      :invalid

    def validate
      super
      errors.add(:validator, "invalid") if invalid
      validates_presence :name
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

    def change_name!
      self.name = "name changed"
      save(raise_on_failure: true)
    end

    def change_name_on_sleep name
      self.name = name
      save(raise_on_failure: true)
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

end
