require 'spec_helper'

describe 'valid transitions bookkeeping' do
  def valid_transitions(event_name)
    ValidTransitionsExample.aasm.state_machine.events[event_name].instance_variable_get(:@valid_transitions)
  end

  it 'clears the entry after a persisted event' do
    model = ValidTransitionsExample.new
    model.run!
    expect(valid_transitions(:run)).not_to have_key(model.object_id)
  end

  it 'clears the entry after a non-persisted event' do
    model = ValidTransitionsExample.new
    model.run
    expect(valid_transitions(:run)).not_to have_key(model.object_id)
  end

  it 'clears the entry when a transition callback raises' do
    model = ValidTransitionsExample.new
    expect { model.crash! }.to raise_error(ArgumentError, 'boom')
    expect(valid_transitions(:crash)).not_to have_key(model.object_id)
  end

  it 'still fires the transition success callback on a persisted event' do
    model = ValidTransitionsExample.new
    expect(model).to receive(:transition_succeeded)
    model.run!
  end

  it 'still fires the event success callback on a persisted event' do
    model = ValidTransitionsExample.new
    expect(model).to receive(:event_succeeded)
    model.run!
  end
end
