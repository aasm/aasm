module Minitest::Assertions
  def assert_event_allowed(object, event, options = {})
    state_machine_name = options.fetch(:on, :default)
    assert object.aasm(state_machine_name).may_fire_event?(event),
          "Expected that the event :#{event} would be allowed (on :#{state_machine_name})"
  end

  def refute_event_allowed(object, event, options = {})
    state_machine_name = options.fetch(:on, :default)
    refute object.aasm(state_machine_name).may_fire_event?(event),
          "Expected that the event :#{event} would not be allowed (on :#{state_machine_name})"
  end
end