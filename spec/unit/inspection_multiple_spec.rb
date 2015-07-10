require 'spec_helper'

describe 'inspection for common cases' do
  it 'should support the new DSL' do
    # 1st state machine
    expect(FooMultiple.aasm(:left)).to respond_to(:states)
    expect(FooMultiple.aasm(:left).states.size).to eql 3
    expect(FooMultiple.aasm(:left).states).to include(:open)
    expect(FooMultiple.aasm(:left).states).to include(:closed)
    expect(FooMultiple.aasm(:left).states).to include(:final)

    expect(FooMultiple.aasm(:left)).to respond_to(:initial_state)
    expect(FooMultiple.aasm(:left).initial_state).to eq(:open)

    expect(FooMultiple.aasm(:left)).to respond_to(:events)
    expect(FooMultiple.aasm(:left).events.size).to eql 2
    expect(FooMultiple.aasm(:left).events).to include(:close)
    expect(FooMultiple.aasm(:left).events).to include(:null)

    # 2nd state machine
    expect(FooMultiple.aasm(:right)).to respond_to(:states)
    expect(FooMultiple.aasm(:right).states.size).to eql 3
    expect(FooMultiple.aasm(:right).states).to include(:green)
    expect(FooMultiple.aasm(:right).states).to include(:yellow)
    expect(FooMultiple.aasm(:right).states).to include(:red)

    expect(FooMultiple.aasm(:right)).to respond_to(:initial_state)
    expect(FooMultiple.aasm(:right).initial_state).to eq(:green)

    expect(FooMultiple.aasm(:right)).to respond_to(:events)
    expect(FooMultiple.aasm(:right).events.size).to eql 3
    expect(FooMultiple.aasm(:right).events).to include(:green)
    expect(FooMultiple.aasm(:right).events).to include(:yellow)
    expect(FooMultiple.aasm(:right).events).to include(:red)
  end

  context "instance level inspection" do
    let(:foo) { FooMultiple.new }
    let(:two) { FooTwoMultiple.new }

    it "delivers all states" do
      # 1st state machine
      states = foo.aasm(:left).states
      expect(states.size).to eql 3
      expect(states).to include(:open)
      expect(states).to include(:closed)
      expect(states).to include(:final)

      states = foo.aasm(:left).states(:permitted => true)
      expect(states.size).to eql 1
      expect(states).to include(:closed)
      expect(states).not_to include(:open)
      expect(states).not_to include(:final)

      foo.close
      expect(foo.aasm(:left).states(:permitted => true)).to be_empty

      # 2nd state machine
      states = foo.aasm(:right).states
      expect(states.size).to eql 3
      expect(states).to include(:green)
      expect(states).to include(:yellow)
      expect(states).to include(:red)

      states = foo.aasm(:right).states(:permitted => true)
      expect(states.size).to eql 1
      expect(states).to include(:yellow)
      expect(states).not_to include(:green)
      expect(states).not_to include(:red)

      foo.yellow
      states = foo.aasm(:right).states(:permitted => true)
      expect(states.size).to eql 2
      expect(states).to include(:red)
      expect(states).to include(:green)
      expect(states).not_to include(:yellow)
    end

    it "delivers all states for subclasses" do
      # 1st state machine
      states = two.aasm(:left).states
      expect(states.size).to eql 4
      expect(states).to include(:open)
      expect(states).to include(:closed)
      expect(states).to include(:final)
      expect(states).to include(:foo)

      states = two.aasm(:left).states(:permitted => true)
      expect(states.size).to eql 1
      expect(states).to include(:closed)
      expect(states).not_to include(:open)

      two.close
      expect(two.aasm(:left).states(:permitted => true)).to be_empty

      # 2nd state machine
      states = two.aasm(:right).states
      expect(states.size).to eql 4
      expect(states).to include(:green)
      expect(states).to include(:yellow)
      expect(states).to include(:red)
      expect(states).to include(:bar)

      states = two.aasm(:right).states(:permitted => true)
      expect(states.size).to eql 1
      expect(states).to include(:yellow)
      expect(states).not_to include(:red)
      expect(states).not_to include(:green)
      expect(states).not_to include(:bar)

      two.yellow
      states = two.aasm(:right).states(:permitted => true)
      expect(states.size).to eql 2
      expect(states).to include(:green)
      expect(states).to include(:red)
      expect(states).not_to include(:yellow)
      expect(states).not_to include(:bar)
    end

    it "delivers all events" do
      # 1st state machine
      events = foo.aasm(:left).events
      expect(events.size).to eql 2
      expect(events).to include(:close)
      expect(events).to include(:null)

      foo.close
      expect(foo.aasm(:left).events).to be_empty

      # 2nd state machine
      events = foo.aasm(:right).events
      expect(events.size).to eql 1
      expect(events).to include(:yellow)
      expect(events).not_to include(:green)
      expect(events).not_to include(:red)

      foo.yellow
      events = foo.aasm(:right).events
      expect(events.size).to eql 2
      expect(events).to include(:green)
      expect(events).to include(:red)
      expect(events).not_to include(:yellow)
    end
  end

  it 'should list states in the order they have been defined' do
    expect(ConversationMultiple.aasm(:left).states).to eq([
      :needs_attention, :read, :closed, :awaiting_response, :junk
    ])
  end
end

describe "special cases" do
  it "should support valid as state name" do
    expect(ValidStateNameMultiple.aasm(:left).states).to include(:invalid)
    expect(ValidStateNameMultiple.aasm(:left).states).to include(:valid)

    argument = ValidStateNameMultiple.new
    expect(argument.invalid?).to be_truthy
    expect(argument.aasm(:left).current_state).to eq(:invalid)

    argument.valid!
    expect(argument.valid?).to be_truthy
    expect(argument.aasm(:left).current_state).to eq(:valid)
  end
end

describe 'aasm.states_for_select' do
  it "should return a select friendly array of states" do
    expect(FooMultiple.aasm(:left)).to respond_to(:states_for_select)
    expect(FooMultiple.aasm(:left).states_for_select).to eq(
      [['Open', 'open'], ['Closed', 'closed'], ['Final', 'final']]
    )
  end
end

describe 'aasm.from_states_for_state' do
  it "should return all from states for a state" do
    expect(ComplexExampleMultiple.aasm(:left)).to respond_to(:from_states_for_state)
    froms = ComplexExampleMultiple.aasm(:left).from_states_for_state(:active)
    [:pending, :passive, :suspended].each {|from| expect(froms).to include(from)}
  end

  it "should return from states for a state for a particular transition only" do
    froms = ComplexExampleMultiple.aasm(:left).from_states_for_state(:active, :transition => :left_unsuspend)
    [:suspended].each {|from| expect(froms).to include(from)}
  end
end

describe 'permitted events' do
  let(:foo) {FooMultiple.new}

  it 'work' do
    expect(foo.aasm(:left).events(:permitted => true)).to include(:close)
    expect(foo.aasm(:left).events(:permitted => true)).not_to include(:null)

    expect(foo.aasm(:right).events(:permitted => true)).to include(:yellow)
    expect(foo.aasm(:right).events(:permitted => true)).not_to include(:green)
    expect(foo.aasm(:right).events(:permitted => true)).not_to include(:red)
  end
end
