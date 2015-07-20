class Gate < ActiveRecord::Base
  include AASM

  # Fake this column for testing purposes
  # attr_accessor :aasm_state

  def value
    'value'
  end

  aasm do
    state :opened
    state :closed

    event :view do
      transitions :to => :read, :from => [:needs_attention]
    end
  end
end

class MultipleGate < ActiveRecord::Base
  include AASM

  # Fake this column for testing purposes
  # attr_accessor :aasm_state

  def value
    'value'
  end

  aasm :left, :column => :aasm_state do
    state :opened
    state :closed

    event :view do
      transitions :to => :read, :from => [:needs_attention]
    end
  end
end
