RSpec::Matchers.define :have_state do |state|
  match do |obj|
    @state_machine_name ||= :default
    obj.aasm(@state_machine_name).current_state == state.to_sym
  end

  chain :on do |state_machine_name|
    @state_machine_name = state_machine_name
  end

  description do
    "have state #{expected} (on :#{@state_machine_name})"
  end

  failure_message do |obj|
    "expected that :#{obj.aasm(@state_machine_name).current_state} would be :#{expected} (on :#{@state_machine_name})"
  end

  failure_message_when_negated do |obj|
    "expected that :#{obj.aasm(@state_machine_name).current_state} would not be :#{expected} (on :#{@state_machine_name})"
  end
end
