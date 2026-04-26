class Parent
  include NoBrainer::Document
  include AASM

  field :status, type: String
  has_many :childs

  aasm column: :status do
    state :unknown_scope
    state :new
  end
end

class Child
  include NoBrainer::Document
  include AASM

  field :status, type: String
  belongs_to :parent

  aasm column: :status do
    state :unknown_scope
    state :new
  end
end
