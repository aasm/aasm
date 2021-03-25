class MultipleNamespaced < ActiveRecord::Base
  include AASM

  aasm(:status, namespace: :car) do
    state :unsold, initial: true
    state :sold

    event :sell do
      transitions from: :unsold, to: :sold
    end

    event :return do
      transitions from: :sold, to: :unsold
    end
  end
end
