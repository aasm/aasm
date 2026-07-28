# frozen_string_literal: true

class NoConstant
  include AASM

  aasm create_constants: false do
    state :initialised, initial: true
    state :filled_out
    state :authorised
  end
end
