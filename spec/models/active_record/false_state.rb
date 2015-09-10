class FalseState < ActiveRecord::Base
  include AASM

  def initialize(*args)
    super
    self.aasm_state = false
  end

  aasm do
    state :opened
    state :closed

    event :view do
      transitions :to => :read, :from => [:needs_attention]
    end
  end
end

class MultipleFalseState < ActiveRecord::Base
  include AASM

  def initialize(*args)
    super
    self.aasm_state = false
  end

  aasm :left do
    state :opened
    state :closed

    event :view do
      transitions :to => :read, :from => [:needs_attention]
    end
  end
end
