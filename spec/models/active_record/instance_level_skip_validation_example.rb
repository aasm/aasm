class InstanceLevelSkipValidationExample < ActiveRecord::Base
  include AASM

  aasm :state do
    state :new, :initial => true
    state :draft
    state :complete

    event :set_draft do
      transitions from: :new, to: :draft
    end

    event :complete do
      transitions from: %i[draft new], to: :complete
    end
  end

  validates :some_string, presence: true
end