class WithEnumWithoutColumn < ActiveRecord::Base
  include AASM

  enum status: {
    opened: 0,
    closed: 1
  }

  aasm :column => :status do
    state :closed, initial: true
    state :opened

    event :view do
      transitions :to => :opened, :from => :closed
    end
  end
end

class MultipleWithEnumWithoutColumn < ActiveRecord::Base
  include AASM

  enum status: {
    opened: 0,
    closed: 1
  }

  aasm :left, :column => :status do
    state :closed, initial: true
    state :opened

    event :view do
      transitions :to => :opened, :from => :closed
    end
  end
end
