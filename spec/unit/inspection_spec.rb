require 'spec_helper'

describe 'inspection for common cases' do
  it 'should support the new DSL' do
    expect(Foo.aasm).to respond_to(:states)
    expect(Foo.aasm.states).to include(:open)
    expect(Foo.aasm.states).to include(:closed)

    expect(Foo.aasm).to respond_to(:initial_state)
    expect(Foo.aasm.initial_state).to eq(:open)

    expect(Foo.aasm).to respond_to(:events)
    expect(Foo.aasm.events).to include(:close)
    expect(Foo.aasm.events).to include(:null)
  end

  context "instance level inspection" do
    let(:foo) { Foo.new }
    let(:two) { FooTwo.new }

    it "delivers all states" do
      states = foo.aasm.states
      expect(states).to include(:open)
      expect(states).to include(:closed)
      expect(states).to include(:final)

      states = foo.aasm.states(:permissible => true)
      expect(states).to include(:closed)
      expect(states).not_to include(:open)
      expect(states).not_to include(:final)

      foo.close
      expect(foo.aasm.states(:permissible => true)).to be_empty
    end

    it "delivers all states for subclasses" do
      states = two.aasm.states
      expect(states).to include(:open)
      expect(states).to include(:closed)
      expect(states).to include(:foo)

      states = two.aasm.states(:permissible => true)
      expect(states).to include(:closed)
      expect(states).not_to include(:open)

      two.close
      expect(two.aasm.states(:permissible => true)).to be_empty
    end

    it "delivers all events" do
      events = foo.aasm.events
      expect(events).to include(:close)
      expect(events).to include(:null)
      foo.close
      expect(foo.aasm.events).to be_empty
    end
  end

  it 'should list states in the order they have been defined' do
    expect(Conversation.aasm.states).to eq([:needs_attention, :read, :closed, :awaiting_response, :junk])
  end
end

describe "special cases" do
  it "should support valid a state name" do
    expect(Argument.aasm.states).to include(:invalid)
    expect(Argument.aasm.states).to include(:valid)

    argument = Argument.new
    expect(argument.invalid?).to be_true
    expect(argument.aasm.current_state).to eq(:invalid)

    argument.valid!
    expect(argument.valid?).to be_true
    expect(argument.aasm.current_state).to eq(:valid)
  end
end

describe 'aasm.states_for_select' do
  it "should return a select friendly array of states" do
    expect(Foo.aasm).to respond_to(:states_for_select)
    expect(Foo.aasm.states_for_select).to eq([['Open', 'open'], ['Closed', 'closed'], ['Final', 'final']])
  end
end

describe 'aasm.from_states_for_state' do
  it "should return all from states for a state" do
    expect(AuthMachine.aasm).to respond_to(:from_states_for_state)
    froms = AuthMachine.aasm.from_states_for_state(:active)
    [:pending, :passive, :suspended].each {|from| expect(froms).to include(from)}
  end

  it "should return from states for a state for a particular transition only" do
    froms = AuthMachine.aasm.from_states_for_state(:active, :transition => :unsuspend)
    [:suspended].each {|from| expect(froms).to include(from)}
  end
end

describe 'permissible events' do
  let(:foo) {Foo.new}

  it 'work' do
    expect(foo.aasm.permissible_events).to include(:close)
    expect(foo.aasm.permissible_events).not_to include(:null)
  end
end
