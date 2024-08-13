class TimestampExampleMongoid
  include Mongoid::Document
  include AASM

  field :status, type: String
  field :opened_at, type: Time

  aasm column: :status, timestamps: true do
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
