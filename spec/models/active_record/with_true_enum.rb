class WithTrueEnum < ActiveRecord::Base
  include AASM

  # Fake this column for testing purposes
  attr_accessor :aasm_state

  def value
    'value'
  end

  aasm :enum => true do
    state :opened
    state :closed

    event :view do
      transitions :to => :read, :from => [:needs_attention]
    end
  end
end

class MultipleWithTrueEnum < ActiveRecord::Base
  include AASM

  # Fake this column for testing purposes
  attr_accessor :aasm_state

  def value
    'value'
  end

  aasm :left, :enum => true do
    state :opened
    state :closed

    event :view do
      transitions :to => :read, :from => [:needs_attention]
    end
  end
end
