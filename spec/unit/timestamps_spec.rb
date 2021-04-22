require 'spec_helper'

describe 'timestamps option' do
  it 'calls a timestamp setter based on the state name when entering a new state' do
    object = TimestampsExample.new
    expect { object.open }.to change { object.opened_at }.from(nil).to(instance_of(::Time))
  end

  it 'overwrites any previous timestamp if a state is entered repeatedly' do
    object = TimestampsExample.new
    object.opened_at = ::Time.new(2000, 1, 1)
    expect { object.open }.to change { object.opened_at }
  end

  it 'does nothing if there is no setter matching the new state' do
    object = TimestampsExample.new
    expect { object.close }.not_to change { object.closed_at }
  end

  it 'can be turned off and on' do
    object = TimestampsExample.new
    object.class.aasm.state_machine.config.timestamps = false
    expect { object.open }.not_to change { object.opened_at }
    object.class.aasm.state_machine.config.timestamps = true
    expect { object.open }.to change { object.opened_at }
  end

  it 'calls a timestamp setter when using a named state machine' do
    object = TimestampsWithNamedMachineExample.new
    expect { object.open }.to change { object.opened_at }.from(nil).to(instance_of(::Time))
  end
end
