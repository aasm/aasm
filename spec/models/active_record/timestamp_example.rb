class TimestampExample < ActiveRecord::Base
  include AASM

  aasm column: :aasm_state, timestamps: true do
    state :opened
    state :closed

    event :open do
      transitions to: :opened
    end

    event :close do
      transitions to: :closed
    end
  end
end
