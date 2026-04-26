class SimpleNewDsl < ActiveRecord::Base
  include AASM
  aasm :column => :status
  aasm do
    state :unknown_scope, :another_unknown_scope
    state :new
  end
end

class MultipleSimpleNewDsl < ActiveRecord::Base
  include AASM
  aasm :left, :column => :status
  aasm :left do
    state :unknown_scope, :another_unknown_scope
    state :new
  end
end

class AbstractClassDsl < ActiveRecord::Base
  include AASM

  self.abstract_class = true

  aasm :column => :status
  aasm do
    state :unknown_scope, :another_unknown_scope
    state :new
  end
end

class ImplementedAbstractClassDsl < AbstractClassDsl
end
