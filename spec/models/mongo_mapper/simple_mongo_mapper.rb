class SimpleMongoMapper
  include MongoMapper::Document
  include AASM

  key :status, String

  aasm column: :status do
    state :unknown_scope, :another_unknown_scope
    state :next
  end
end

class SimpleMongoMapperMultiple
  include MongoMapper::Document
  include AASM

  key :status, String

  aasm :left, column: :status do
    state :unknown_scope, :another_unknown_scope
    state :next
  end
end
