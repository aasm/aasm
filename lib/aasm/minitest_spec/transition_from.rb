module MiniTest::Assertions
  def assert_transitions_from(object, from_state, *args, **options)
    options[:on] ||= :default
    assert _transitions_from?(object, from_state, args, options),
          "Expected transition state to :#{options[:to]} from :#{from_state} on event :#{options[:on_event]}, (on :#{options[:on]})"
  end

  def refute_transitions_from(object, from_state, *args, **options)
    options[:on] ||= :default
    refute _transitions_from?(object, from_state, args, options),
          "Expected transition state to :#{options[:to]} from :#{from_state} on event :#{options[:on_event]}, (on :#{options[:on]})"
  end

  def _transitions_from?(object, from_state, *args, **options)
    state_machine_name = options[:on] || :default
    object.aasm(state_machine_name).current_state = from_state.to_sym
    object.send(options[:on_event], *args) && options[:to].to_sym == object.aasm(state_machine_name).current_state
  end

  Object.infect_an_assertion :assert_transitions_from, :must_transition_from, :do_not_flip
  Object.infect_an_assertion :refute_transitions_from, :wont_transition_from, :do_not_flip
end