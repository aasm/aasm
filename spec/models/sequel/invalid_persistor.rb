db = Sequel::DATABASES.first || Sequel.connect(SEQUEL_DB)

[:invalid_persistors, :multiple_invalid_persistors].each do |table_name|
  db.create_table(table_name) do
    primary_key :id
    String "name"
    String "status"
  end
end

module Sequel
  class InvalidPersistor < Sequel::Model(:invalid_persistors)
    plugin :validation_helpers

    include AASM
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

    def validate
      super
      validates_presence :name
    end
  end

  class MultipleInvalidPersistor < Sequel::Model(:multiple_invalid_persistors)
    plugin :validation_helpers

    include AASM
    aasm :left, :column => :status, :skip_validation_on_save => true do
      state :sleeping, :initial => true
      state :running
      event :run do
        transitions :to => :running, :from => :sleeping
      end
      event :sleep do
        transitions :to => :sleeping, :from => :running
      end
    end
    def validate
      super
      validates_presence :name
    end
  end
end
