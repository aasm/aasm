class DefaultState
  attr_accessor :transient_store
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

class ProvidedState
  attr_accessor :transient_store
  include AASM
  aasm do
    state :alpha, :initial => true
    state :beta
    state :gamma
    event :release do
      transitions :from => [:alpha, :beta, :gamma], :to => :beta
    end
  end

  def aasm_read_state
    :beta
  end

  def aasm_write_state(new_state)
    @transient_store = new_state
  end
end

class PersistedState < ActiveRecord::Base
  attr_accessor :transient_store
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

class ProvidedAndPersistedState < ActiveRecord::Base
  attr_accessor :transient_store
  include AASM
  aasm do
    state :alpha, :initial => true
    state :beta
    state :gamma
    event :release do
      transitions :from => [:alpha, :beta, :gamma], :to => :beta
    end
  end

  def aasm_read_state
    :gamma
  end

  def aasm_write_state(new_state)
    @transient_store = new_state
  end
end
