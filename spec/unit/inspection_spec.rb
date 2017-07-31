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
    let(:multi) { MultiTransitioner.new }

    it "delivers all states" do
      states = foo.aasm.states
      expect(states).to include(:open)
      expect(states).to include(:closed)
      expect(states).to include(:final)

      permitted_states = foo.aasm.states(:permitted => true)
      expect(permitted_states).to include(:closed)
      expect(permitted_states).not_to include(:open)
      expect(permitted_states).not_to include(:final)

      blocked_states = foo.aasm.states(:permitted => false)
      expect(blocked_states).to include(:closed)
      expect(blocked_states).not_to include(:open)
      expect(blocked_states).to include(:final)

      foo.close
      expect(foo.aasm.states(:permitted => true)).to be_empty
    end

    it "delivers all states for subclasses" do
      states = two.aasm.states
      expect(states).to include(:open)
      expect(states).to include(:closed)
      expect(states).to include(:final)
      expect(states).to include(:foo)

      states = two.aasm.states(:permitted => true)
      expect(states).to include(:closed)
      expect(states).not_to include(:open)
      expect(states).not_to include(:final)

      two.close
      expect(two.aasm.states(:permitted => true)).to be_empty
    end

    it "delivers all events" do
      events = foo.aasm.events
      expect(events).to include(:close)
      expect(events).to include(:null)
      foo.close
      expect(foo.aasm.events).to be_empty
    end

    it "delivers permitted states when multiple transitions are defined" do
      multi.can_run = false
      states = multi.aasm.states(:permitted => true)
      expect(states).to_not include(:running)
      expect(states).to include(:dancing)

      multi.can_run = true
      states = multi.aasm.states(:permitted => true)
      expect(states).to include(:running)
      expect(states).to_not include(:dancing)
    end

    it "transitions to correct state if from state is missing from one transitions" do
      multi.sleep
      expect(multi.aasm.current_state).to eq(:sleeping)
    end
  end

  it 'should list states in the order they have been defined' do
    expect(Conversation.aasm.states).to eq([:needs_attention, :read, :closed, :awaiting_response, :junk])
  end
end

describe "special cases" do
  it "should support valid as state name" do
    expect(ValidStateName.aasm.states).to include(:invalid)
    expect(ValidStateName.aasm.states).to include(:valid)

    argument = ValidStateName.new
    expect(argument.invalid?).to be_truthy
    expect(argument.aasm.current_state).to eq(:invalid)

    argument.valid!
    expect(argument.valid?).to be_truthy
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
    expect(ComplexExample.aasm).to respond_to(:from_states_for_state)
    froms = ComplexExample.aasm.from_states_for_state(:active)
    [:pending, :passive, :suspended].each {|from| expect(froms).to include(from)}
  end

  it "should return from states for a state for a particular transition only" do
    froms = ComplexExample.aasm.from_states_for_state(:active, :transition => :unsuspend)
    [:suspended].each {|from| expect(froms).to include(from)}
  end
end

describe 'permitted events' do
  let(:foo) {Foo.new}

  it 'work' do
    expect(foo.aasm.events(:permitted => true)).to include(:close)
    expect(foo.aasm.events(:permitted => true)).not_to include(:null)
  end

  it 'should not include events in the reject option' do
    expect(foo.aasm.events(:permitted => true, reject: :close)).not_to include(:close)
    expect(foo.aasm.events(:permitted => true, reject: [:close])).not_to include(:close)
  end
end

describe 'not permitted events' do
  let(:foo) {Foo.new}

  it 'work' do
    expect(foo.aasm.events(:permitted => false)).to include(:null)
    expect(foo.aasm.events(:permitted => false)).not_to include(:close)
  end

  it 'should not include events in the reject option' do
    expect(foo.aasm.events(:permitted => false, reject: :null)).to eq([])
  end
end
