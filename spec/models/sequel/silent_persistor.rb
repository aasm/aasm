db = Sequel::DATABASES.first || Sequel.connect(SEQUEL_DB)

[:silent_persistors, :multiple_silent_persistors].each do |t|
  db.create_table(t) do
    primary_key :id
    String "name"
    String "status"
  end
end

module Sequel
  class SilentPersistor < Sequel::Model(:silent_persistors)
    plugin :validation_helpers

    include AASM
    aasm :column => :status, :whiny_persistence => false do
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
      validates_presence :name
    end
  end

  class MultipleSilentPersistor< Sequel::Model(:multiple_silent_persistors)
    plugin :validation_helpers

    include AASM
    aasm :left, :column => :status, :whiny_persistence => false do
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
      validates_presence :name
    end
  end
end
