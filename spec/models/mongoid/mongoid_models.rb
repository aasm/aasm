class SimpleMongoid
  include Mongoid::Document
  include AASM

  field :status, type: String

  aasm_column :status
  aasm_state :unknown_scope
  aasm_state :new
end

class SimpleNewDslMongoid
  include Mongoid::Document
  include AASM

  field :status, type: String

  aasm :column => :status
  aasm do
    state :unknown_scope
    state :new
  end
end