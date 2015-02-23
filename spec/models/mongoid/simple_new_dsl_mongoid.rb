class SimpleNewDslMongoid
  include Mongoid::Document
  include AASM

  field :status, :type => String

  aasm :column => :status
  aasm do
    state :unknown_scope, :initial => true
    state :new
  end
end
