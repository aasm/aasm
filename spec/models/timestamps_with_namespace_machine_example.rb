class TimestampsWithNamespaceMachineExample
  include AASM

  attr_accessor :new_opened_at

  aasm :my_state, timestamps: true, namespace: :new do
    state :opened

    event :open do
      transitions to: :opened
    end
  end
end
