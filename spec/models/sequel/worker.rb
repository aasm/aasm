db = Sequel::DATABASES.first || Sequel.connect(SEQUEL_DB)

db.create_table(:workers) do
  primary_key :id
  String "name"
  String "status"
end

module Sequel
  class Worker < Sequel::Model(:workers)
  end
end
