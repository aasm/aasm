class NoScopeMongoMapper
  include MongoMapper::Document
  include AASM

  key :status, String

  aasm :create_scopes => false, :column => :status do
    state :ignored_scope
  end
end

class NoScopeMongoMapperMultiple
  include MongoMapper::Document
  include AASM

  key :status, String

  aasm :left, :create_scopes => false, :column => :status do
    state :ignored_scope
  end
end
