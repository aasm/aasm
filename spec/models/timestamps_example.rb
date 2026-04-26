class TimestampsExample
  include AASM

  attr_accessor :opened_at
  attr_reader :closed_at

  aasm timestamps: true do
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
