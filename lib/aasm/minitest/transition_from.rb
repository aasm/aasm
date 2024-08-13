module Minitest::Assertions
  def assert_transitions_from(object, from_state, *args)
    options = args.first
    options[:on] ||= :default
    assert _transitions_from?(object, from_state, args, options),
          "Expected transition state to :#{options[:to]} from :#{from_state} on event :#{options[:on_event]}, (on :#{options[:on]})"
  end

  def refute_transitions_from(object, from_state, *args)
    options = args.first
    options[:on] ||= :default
    refute _transitions_from?(object, from_state, args, options),
          "Expected transition state to :#{options[:to]} from :#{from_state} on event :#{options[:on_event]}, (on :#{options[:on]})"
  end

  def _transitions_from?(object, from_state, args, options)
    state_machine_name = options[:on]
    object.aasm(state_machine_name).current_state = from_state.to_sym
    object.send(options[:on_event], *args) && options[:to].to_sym == object.aasm(state_machine_name).current_state
  end
end
