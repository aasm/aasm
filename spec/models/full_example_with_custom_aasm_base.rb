class FullExampleWithCustomAasmBase
  include AASM

  aasm with_klass: CustomAasmBase do
    state :initialised, :initial => true
    state :filled_out

    event :fill_out, :some_option => '-- some event value --' do
      another_option '-- another event value --'
      custom_event_method!(41)

      transitions :from => :initialised, :to => :filled_out, :some_option => '-- some transition value --' do
        another_option '-- another transition value --'
        custom_transition_method! 42
      end
    end
  end
end
