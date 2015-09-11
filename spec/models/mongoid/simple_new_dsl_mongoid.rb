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

class SimpleNewDslMongoidMultiple
  include Mongoid::Document
  include AASM

  field :status, :type => String

  aasm :left, :column => :status
  aasm :left do
    state :unknown_scope, :initial => true
    state :new
  end
end
