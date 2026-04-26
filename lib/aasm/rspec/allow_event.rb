RSpec::Matchers.define :allow_event do |event|
  match do |obj|
    @state_machine_name ||= :default
    obj.aasm(@state_machine_name).may_fire_event?(event, *@args)
  end

  chain :on do |state_machine_name|
    @state_machine_name = state_machine_name
  end

  chain :with do |*args|
    @args = args
  end

  description do
    "allow event #{expected} (on :#{@state_machine_name})"
  end

  failure_message do |obj|
    "expected that the event :#{expected} would be allowed (on :#{@state_machine_name})"
  end

  failure_message_when_negated do |obj|
    "expected that the event :#{expected} would not be allowed (on :#{@state_machine_name})"
  end
end
