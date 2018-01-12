class NoScopeNoBrainer
  include NoBrainer::Document
  include AASM

  field :status, type: String

  aasm create_scopes: false, column: :status do
    state :ignored_scope
  end
end

class NoScopeNoBrainerMultiple
  include NoBrainer::Document
  include AASM

  field :status, type: String

  aasm :left, create_scopes: false, column: :status do
    state :ignored_scope
  end
end
