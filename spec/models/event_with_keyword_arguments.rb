class EventWithKeywordArguments
  include AASM

  aasm do
    state :open, :initial => true, :column => :status
    state :closed

    event :close do
      before :_before_close
      transitions from: :open, to: :closed
    end
  end

  def _before_close(key:)
  end
end
