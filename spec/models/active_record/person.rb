class Base < ActiveRecord::Base
  include AASM

  aasm column: 'status' do
    state :inactive, initial: true
    state :active

    event :activate do
      transitions from: :inactive, to: :active
    end

    event :deactivate do
      transitions from: :active, to: :inactive
    end
  end

  self.abstract_class = true
  self.table_name = 'users'
end


class Person < Base
end
