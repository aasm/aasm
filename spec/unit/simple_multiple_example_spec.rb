require 'spec_helper'

describe 'state machine' do
  let(:simple) { SimpleMultipleExample.new }

  it 'starts with an initial state' do
    expect(simple.aasm(:move).current_state).to eq(:standing)
    expect(simple).to respond_to(:standing?)
    expect(simple).to be_standing

    expect(simple.aasm(:work).current_state).to eq(:sleeping)
    expect(simple).to respond_to(:sleeping?)
    expect(simple).to be_sleeping
  end

  it 'allows transitions to other states' do
    expect(simple).to respond_to(:walk)
    expect(simple).to respond_to(:walk!)
    simple.walk!
    expect(simple).to respond_to(:walking?)
    expect(simple).to be_walking

    expect(simple).to respond_to(:run)
    expect(simple).to respond_to(:run!)
    simple.run
    expect(simple).to respond_to(:running?)
    expect(simple).to be_running

    expect(simple).to respond_to(:start)
    expect(simple).to respond_to(:start!)
    simple.start
    expect(simple).to respond_to(:processing?)
    expect(simple).to be_processing
  end

  it 'denies transitions to other states' do
    expect {simple.hold}.to raise_error(AASM::InvalidTransition)
    expect {simple.hold!}.to raise_error(AASM::InvalidTransition)
    simple.walk
    expect {simple.walk}.to raise_error(AASM::InvalidTransition)
    expect {simple.walk!}.to raise_error(AASM::InvalidTransition)
    simple.run
    expect {simple.walk}.to raise_error(AASM::InvalidTransition)
    expect {simple.walk!}.to raise_error(AASM::InvalidTransition)

    expect {simple.stop}.to raise_error(AASM::InvalidTransition)
    expect {simple.stop!}.to raise_error(AASM::InvalidTransition)
    simple.start
    expect {simple.start}.to raise_error(AASM::InvalidTransition)
    expect {simple.start!}.to raise_error(AASM::InvalidTransition)
    simple.stop
  end

  it 'defines constants for each state name' do
    expect(SimpleMultipleExample::STATE_STANDING).to eq(:standing)
    expect(SimpleMultipleExample::STATE_WALKING).to eq(:walking)
    expect(SimpleMultipleExample::STATE_RUNNING).to eq(:running)

    expect(SimpleMultipleExample::STATE_SLEEPING).to eq(:sleeping)
    expect(SimpleMultipleExample::STATE_PROCESSING).to eq(:processing)
    expect(SimpleMultipleExample::STATE_RUNNING).to eq(:running)
  end

  context 'triggers binding_events in bindind_state_machine' do
    it 'does persist' do
      expect(simple).to be_sleeping
      expect(simple).to be_answered
      expect(simple).to receive(:start!).and_call_original
      simple.ask!
      expect(simple).to be_asked
      expect(simple).to be_processing
      expect(simple).to receive(:stop!).and_call_original
      simple.answer!
      expect(simple).to be_sleeping
      expect(simple).to be_answered
    end

    it 'does not persist' do
      expect(simple).to be_sleeping
      expect(simple).to be_answered
      expect(simple).to receive(:start).and_call_original
      simple.ask
      expect(simple).to be_asked
      expect(simple).to be_processing
      expect(simple).to receive(:stop).and_call_original
      simple.answer
      expect(simple).to be_sleeping
      expect(simple).to be_answered
    end
  end
end
