class SimpleNoBrainer
  include NoBrainer::Document
  include AASM

  field :status, type: String

  aasm column: :status do
    state :unknown_scope, :another_unknown_scope
    state :new
  end
end

class SimpleNoBrainerMultiple
  include NoBrainer::Document
  include AASM

  field :status, type: String

  aasm :left, column: :status do
    state :unknown_scope, :another_unknown_scope
    state :new
  end
end
