class SimpleNewDslMongoMapper
  include MongoMapper::Document
  include AASM

  key :status, String

  aasm :column => :status
  aasm do
    state :unknown_scope
    state :next
  end
end

class SimpleNewDslMongoMapperMultiple
  include MongoMapper::Document
  include AASM

  key :status, String

  aasm :left, :column => :status
  aasm :left do
    state :unknown_scope
    state :next
  end
end
