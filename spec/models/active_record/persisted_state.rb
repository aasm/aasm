class PersistedState < ActiveRecord::Base
  attr_accessor :transient_store, :persisted_store
  include AASM
  aasm do
    state :alpha, :initial => true
    state :beta
    state :gamma
    event :release do
      transitions :from => [:alpha, :beta, :gamma], :to => :beta
    end
  end
end
