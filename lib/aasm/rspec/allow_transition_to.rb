RSpec::Matchers.define :allow_transition_to do |state|
  match do |obj|
    @state_machine_name ||= :default
    obj.aasm(@state_machine_name).states({:permitted => true}, *@args).include?(state)
  end

  chain :on do |state_machine_name|
    @state_machine_name = state_machine_name
  end

  chain :with do |*args|
    @args = args
  end

  description do
    "allow transition to #{expected} (on :#{@state_machine_name})"
  end

  failure_message do |obj|
    "expected that the state :#{expected} would be reachable (on :#{@state_machine_name})"
  end

  failure_message_when_negated do |obj|
    "expected that the state :#{expected} would not be reachable (on :#{@state_machine_name})"
  end
end
