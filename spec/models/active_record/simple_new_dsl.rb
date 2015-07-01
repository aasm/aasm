class SimpleNewDsl < ActiveRecord::Base
  include AASM
  aasm :column => :status
  aasm do
    state :unknown_scope
    state :new
  end
end

class MultipleSimpleNewDsl < ActiveRecord::Base
  include AASM
  aasm :left, :column => :status
  aasm :left do
    state :unknown_scope
    state :new
  end
end
