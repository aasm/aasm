require 'spec_helper'

describe 'current event' do
  let(:pe) {ParametrisedEventMultiple.new}

  it 'if no event has been triggered' do
    expect(pe.aasm(:left).current_event).to be_nil
  end

  it 'if a event has been triggered' do
    pe.wakeup
    expect(pe.aasm(:left).current_event).to eql :wakeup
  end

  it 'if no event has been triggered' do
    pe.wakeup!
    expect(pe.aasm(:left).current_event).to eql :wakeup!
  end
end

describe 'parametrised events' do
  let(:pe) {ParametrisedEventMultiple.new}

  it 'should transition to specified next state (sleeping to showering)' do
    pe.wakeup!(:showering)
    expect(pe.aasm(:left).current_state).to eq(:showering)
  end

  it 'should transition to specified next state (sleeping to working)' do
    pe.wakeup!(:working)
    expect(pe.aasm(:left).current_state).to eq(:working)
  end

  it 'should transition to default (first or showering) state' do
    pe.wakeup!
    expect(pe.aasm(:left).current_state).to eq(:showering)
  end

  it 'should transition to default state when :after transition invoked' do
    pe.dress!('purple', 'dressy')
    expect(pe.aasm(:left).current_state).to eq(:working)
  end

  it 'should call :after transition method with args' do
    pe.wakeup!(:showering)
    expect(pe).to receive(:wear_clothes).with('blue', 'jeans')
    pe.dress!(:working, 'blue', 'jeans')
  end

  it 'should call :after transition proc' do
    pe.wakeup!(:showering)
    expect(pe).to receive(:wear_clothes).with('purple', 'slacks')
    pe.dress!(:dating, 'purple', 'slacks')
  end

  it 'should call :after transition with an array of methods' do
    pe.wakeup!(:showering)
    expect(pe).to receive(:condition_hair)
    expect(pe).to receive(:fix_hair)
    pe.dress!(:prettying_up)
  end
end

describe 'event firing without persistence' do
  it 'should attempt to persist if aasm_write_state is defined' do
    foo = Foo.new
    def foo.aasm_write_state; end
    expect(foo).to be_open

    expect(foo).to receive(:aasm_write_state_without_persistence)
    foo.close
  end
end
