class BasicActiveRecordTwoStateMachinesExample < ActiveRecord::Base
  include AASM

  aasm :search do
    state :initialised, :initial => true
    state :queried
    state :requested

    event :query do
      transitions :from => [:initialised, :requested], :to => :queried
    end
    event :request do
      transitions :from => :queried, :to => :requested
    end
  end

  aasm :sync do
    state :unsynced, :initial => true
    state :synced

    event :synchronise do
      transitions :from => :unsynced, :to => :synced
    end
  end
end
