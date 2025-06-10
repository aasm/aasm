# frozen_string_literal: true

class WithAlias < ActiveRecord::Base
  include AASM

  alias_attribute :aasm_state_alias, :aasm_state

  aasm :aasm_state_alias do
    state :active, initial: true
    state :inactive

    event :activate do
      transitions from: :inactive, to: :active
    end

    event :deactivate do
      transitions from: :active, to: :inactive
    end
  end
end
