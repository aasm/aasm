class SimpleMongoid
  include Mongoid::Document
  include AASM::Methods

  field :status, :type => String

  aasm column: :status do
    state :unknown_scope
    state :new
  end
end
