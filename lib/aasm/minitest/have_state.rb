module Minitest::Assertions
  def assert_have_state(object, state, options = {})
    state_machine_name = options.fetch(:on, :default)
    assert object.aasm(state_machine_name).current_state == state,
         "Expected that :#{object.aasm(state_machine_name).current_state} would be :#{state} (on :#{state_machine_name})"
  end

  def refute_have_state(object, state, options = {})
    state_machine_name = options.fetch(:on, :default)
    refute object.aasm(state_machine_name).current_state == state,
         "Expected that :#{object.aasm(state_machine_name).current_state} would be :#{state} (on :#{state_machine_name})"
  end
end