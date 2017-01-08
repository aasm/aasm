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

class TimestampGate < ActiveRecord::Base
  include AASM

  # Fake this column for testing purposes
   attr_accessor :gate_opened_at

  def value
    'value'
  end

  aasm timestamp: true do
    state :opened, timestamp: :gate_opened_at
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
