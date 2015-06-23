class WithEnum < ActiveRecord::Base
  include AASM

  enum :status => {
    :opened => 0,
    :closed => 1
  }

  # Fake this column for testing purposes
  # attr_accessor :aasm_state

  def self.test
    {}
  end

  aasm :enum => true, :column => :status, :skip_validation_on_save => true, :no_direct_assignment => true do
    state :opened
    state :closed

    event :close do
      transitions :from => :opened, :to => :closed
    end
  end
end
