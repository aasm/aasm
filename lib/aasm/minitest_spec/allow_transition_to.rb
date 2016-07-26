module Minitest::Assertions
  def assert_transition_to_allowed(object, to_state, *args, **options)
    state_machine_name = options[:on] || :default
    assert object.aasm(state_machine_name).states(permitted: true).include?(to_state),
           "Expected that the state :#{to_state} would be reachable (on :#{state_machine_name})"
  end

  def refute_transition_to_allowed(object, to_state, *args, **options)
    state_machine_name = options[:on] || :default
    refute object.aasm(state_machine_name).states(permitted: true).include?(to_state),
           "Expected that the state :#{to_state} would be reachable (on :#{state_machine_name})"
  end

  Object.infect_an_assertion :assert_transition_to_allowed, :must_allow_transition_to, :do_not_flip
  Object.infect_an_assertion :refute_transition_to_allowed, :wont_allow_transition_to, :do_not_flip
end
