class DefaultState
  attr_accessor :transient_store, :persisted_store
  include AASM
  aasm do
    state :alpha, :initial => true, display: 'ALPHA'
    state :beta
    state :gamma
    event :release do
      transitions :from => [:alpha, :beta, :gamma], :to => :beta
    end
  end
end
