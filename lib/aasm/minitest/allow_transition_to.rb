module Minitest::Assertions
  def assert_transition_to_allowed(object, to_state, options = {})
    state_machine_name = options.fetch(:on, :default)
    assert object.aasm(state_machine_name).states(permitted: true).include?(to_state),
           "Expected that the state :#{to_state} would be reachable (on :#{state_machine_name})"
  end

  def refute_transition_to_allowed(object, to_state, options = {})
    state_machine_name = options.fetch(:on, :default)
    refute object.aasm(state_machine_name).states(permitted: true).include?(to_state),
           "Expected that the state :#{to_state} would be reachable (on :#{state_machine_name})"
  end
end
