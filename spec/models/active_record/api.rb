class DefaultState
  include AASM
  aasm do
    state :alpha, :initial => true
    state :beta
    state :gamma
  end
end

class ProvidedState
  include AASM
  aasm do
    state :alpha, :initial => true
    state :beta
    state :gamma
  end

  def aasm_read_state
    :beta
  end
end

class PersistedState < ActiveRecord::Base
  include AASM
  aasm do
    state :alpha, :initial => true
    state :beta
    state :gamma
  end
end

class ProvidedAndPersistedState < ActiveRecord::Base
  include AASM
  aasm do
    state :alpha, :initial => true
    state :beta
    state :gamma
  end

  def aasm_read_state
    :gamma
  end
end
