class ProvidedAndPersistedState < ActiveRecord::Base
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

  def aasm_read_state(*args)
    :gamma
  end

  def aasm_write_state(new_state, *args)
    @persisted_store = new_state
  end

  def aasm_write_state_without_persistence(new_state, *args)
    @transient_store = new_state
  end
end
