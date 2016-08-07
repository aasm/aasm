module Minitest::Assertions
  def assert_have_state(object, state, **options)
    state_machine_name = options[:on] || :default
    assert object.aasm(state_machine_name).current_state == state,
         "Expected that :#{object.aasm(state_machine_name).current_state} would be :#{state} (on :#{state_machine_name})"
  end

  def refute_have_state(object, state, **options)
    state_machine_name = options[:on] || :default
    refute object.aasm(state_machine_name).current_state == state,
         "Expected that :#{object.aasm(state_machine_name).current_state} would be :#{state} (on :#{state_machine_name})"
  end

  Object.infect_an_assertion :assert_have_state, :must_have_state, :do_not_flip
  Object.infect_an_assertion :refute_have_state, :wont_have_state, :do_not_flip
end