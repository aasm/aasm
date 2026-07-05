require 'spec_helper'

describe 'namespaced state machines with identical event names' do
  let(:example) { CollisionNamespacedExample.new }

  it 'starts both machines in their initial states' do
    expect(example.aasm(:work).current_state).to eq(:idle)
    expect(example.aasm(:engine).current_state).to eq(:idle)
    expect(example).to be_work_idle
    expect(example).to be_engine_idle
  end

  it 'defines namespaced event methods without collision' do
    expect(example).to respond_to(:start_work)
    expect(example).to respond_to(:start_work!)
    expect(example).to respond_to(:may_start_work?)
    expect(example).to respond_to(:stop_work)
    expect(example).to respond_to(:stop_work!)
    expect(example).to respond_to(:may_stop_work?)

    expect(example).to respond_to(:start_engine)
    expect(example).to respond_to(:start_engine!)
    expect(example).to respond_to(:may_start_engine?)
    expect(example).to respond_to(:stop_engine)
    expect(example).to respond_to(:stop_engine!)
    expect(example).to respond_to(:may_stop_engine?)
  end

  it 'does not define plain-named event methods' do
    expect(example).not_to respond_to(:start)
    expect(example).not_to respond_to(:start!)
    expect(example).not_to respond_to(:may_start?)
    expect(example).not_to respond_to(:stop)
    expect(example).not_to respond_to(:stop!)
    expect(example).not_to respond_to(:may_stop?)
  end

  it 'transitions each machine independently' do
    expect(example).to be_work_idle
    expect(example).to be_engine_idle

    example.start_work!
    expect(example).to be_work_running
    expect(example).to be_engine_idle

    example.start_engine!
    expect(example).to be_work_running
    expect(example).to be_engine_running

    example.stop_work!
    expect(example).to be_work_idle
    expect(example).to be_engine_running
  end

  it 'reports correct may_fire? for each machine' do
    expect(example.may_start_work?).to be true
    expect(example.may_stop_work?).to be false
    expect(example.may_start_engine?).to be true
    expect(example.may_stop_engine?).to be false

    example.start_work!
    expect(example.may_start_work?).to be false
    expect(example.may_stop_work?).to be true
    expect(example.may_start_engine?).to be true
    expect(example.may_stop_engine?).to be false
  end

  it 'supports fire/fire! via aasm instance with plain event names' do
    example.aasm(:work).fire!(:start)
    expect(example).to be_work_running
    expect(example).to be_engine_idle

    example.aasm(:engine).fire!(:start)
    expect(example).to be_engine_running
  end
end
