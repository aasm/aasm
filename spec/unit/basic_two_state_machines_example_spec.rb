require 'spec_helper'

describe 'on initialization' do
  let(:example) { BasicTwoStateMachinesExample.new }

  it 'should be in the initial state' do
    expect(example.aasm(:search).current_state).to eql :initialised
    expect(example.aasm(:sync).current_state).to eql :unsynced
  end
end
