class EventWithKeywordArguments
  include AASM

  aasm do
    state :open, :initial => true, :column => :status
    state :closed

    event :close do
      before :_before_close
      transitions from: :open, to: :closed
    end

    event :another_close do
      before :_before_another_close
      transitions from: :open, to: :closed
    end
  end

  def _before_close(key:)
  end

  def _before_another_close(foo, key: nil)
  end
end
