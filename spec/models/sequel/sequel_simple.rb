db = Sequel::DATABASES.first || Sequel.connect(SEQUEL_DB)

# if you want to see the statements while running the spec enable the following line
# db.loggers << Logger.new($stderr)
db.create_table(:simples) do
  primary_key :id
  String :status
end

module Sequel
  class Simple < Sequel::Model(:simples)
    include AASM

    attr_accessor :default

    aasm :column => :status
    aasm do
      state :alpha, :initial => true
      state :beta
      state :gamma
      event :release do
        transitions :from => [:alpha, :beta, :gamma], :to => :beta
      end
    end
  end
end
