class SimpleNewDslMongoid
  include Mongoid::Document
  include AASM::Methods

  field :status, :type => String

  aasm :column => :status
  aasm do
    state :unknown_scope
    state :new
  end
end
