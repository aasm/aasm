class NoScopeMongoid
  include Mongoid::Document
  include AASM::Methods

  field :status, :type => String

  aasm :create_scopes => false, :column => :status do
    state :ignored_scope
  end
end
