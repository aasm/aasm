class SimpleExampleWithCustomAasmBase
  include AASM

  aasm with_klass: CustomAasmBase do
    state :initialised, :initial => true
    state :filled_out

    event :fill_out do
      transitions :from => :initialised, :to => :filled_out
    end
  end
end
