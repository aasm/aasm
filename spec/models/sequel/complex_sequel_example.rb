db = Sequel::DATABASES.first || Sequel.connect(SEQUEL_DB)

# if you want to see the statements while running the spec enable the following line
# db.loggers << Logger.new($stderr)
db.create_table(:complex_sequel_examples) do
  primary_key :id
  String :left
  String :right
end

module Sequel
class ComplexExample < Sequel::Model(:complex_sequel_examples)

  include AASM

  aasm :left, :column => 'left' do
    state :one, :initial => true
    state :two
    state :three

    event :increment do
      transitions :from => :one, :to => :two
      transitions :from => :two, :to => :three
    end
    event :reset do
      transitions :from => :three, :to => :one
    end
  end

  aasm :right, :column => 'right' do
    state :alpha, :initial => true
    state :beta
    state :gamma

    event :level_up do
      transitions :from => :alpha, :to => :beta
      transitions :from => :beta, :to => :gamma
    end
    event :level_down do
      transitions :from => :gamma, :to => :beta
      transitions :from => :beta, :to => :alpha
    end
  end

end
end
