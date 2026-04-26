class TimestampsWithNamedMachineExample
  include AASM

  attr_accessor :opened_at

  aasm :my_state, timestamps: true do
    state :opened

    event :open do
      transitions to: :opened
    end
  end
end
