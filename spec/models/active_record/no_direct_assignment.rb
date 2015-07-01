class NoDirectAssignment < ActiveRecord::Base
  include AASM
  aasm :no_direct_assignment => true do
    state :pending, :initial => true
    state :running
    event :run do
      transitions :from => :pending, :to => :running
    end
  end
end

class MultipleNoDirectAssignment < ActiveRecord::Base
  include AASM
  aasm :left, :no_direct_assignment => true do
    state :pending, :initial => true
    state :running
    event :run do
      transitions :from => :pending, :to => :running
    end
  end
end
