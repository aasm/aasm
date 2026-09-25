class AliasedState < ActiveRecord::Base
  include AASM

  alias_attribute :state, :status

  aasm :column => :state do
    state :pending, :initial => true
    state :running
  end
end
