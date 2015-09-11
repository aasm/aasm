class NoScope < ActiveRecord::Base
  include AASM
  aasm :create_scopes => false do
    state :pending, :initial => true
    state :running
    event :run do
      transitions :from => :pending, :to => :running
    end
  end
end

class MultipleNoScope < ActiveRecord::Base
  include AASM
  aasm :left, :column => :aasm_state, :create_scopes => false do
    state :pending, :initial => true
    state :running
    event :run do
      transitions :from => :pending, :to => :running
    end
  end
end
