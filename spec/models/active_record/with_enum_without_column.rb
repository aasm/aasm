class WithEnumWithoutColumn < ActiveRecord::Base
  include AASM

  if ActiveRecord::VERSION::MAJOR >= 4 && ActiveRecord::VERSION::MINOR >= 1 # won't work with Rails <= 4.1
    enum status: {
      opened: 0,
      closed: 1
    }
  end

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
  if ActiveRecord::VERSION::MAJOR >= 4 && ActiveRecord::VERSION::MINOR >= 1 # won't work with Rails <= 4.1
    enum status: {
      opened: 0,
      closed: 1
    }
  end

  aasm :left, :column => :status do
    state :closed, initial: true
    state :opened

    event :view do
      transitions :to => :opened, :from => :closed
    end
  end
end
