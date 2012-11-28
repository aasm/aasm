require 'spec_helper'

# all of these should be tested per case
# describe AASM, '- class level definitions' do
#   it 'should define a class level methods on its including class' do
#     Foo.should respond_to(:aasm_initial_state)
#     Foo.should respond_to(:aasm_state)
#     Foo.should respond_to(:aasm_event)
#     Foo.should respond_to(:aasm_states)
#     Foo.should respond_to(:aasm_states_for_select)
#     Foo.should respond_to(:aasm_events)
#     Foo.should respond_to(:aasm_from_states_for_state)
#   end
# end

describe 'inspection for common cases' do
  it 'should support the old DSL' do
    Foo.aasm_states.should include(:open)
    Foo.aasm_states.should include(:closed)
    Foo.aasm_initial_state.should == :open
    Foo.aasm_events.should include(:close)
    Foo.aasm_events.should include(:null)
  end

  it 'should support the new DSL' do
    Foo.aasm.states.should include(:open)
    Foo.aasm.states.should include(:closed)
    Foo.aasm.initial_state.should == :open
    Foo.aasm.events.should include(:close)
    Foo.aasm.events.should include(:null)
  end

  it 'should list states in the order they have been defined' do
    Conversation.aasm.states.should == [:needs_attention, :read, :closed, :awaiting_response, :junk]
  end
end

describe "special cases" do
  it "should support valid a state name" do
    Argument.aasm_states.should include(:invalid)
    Argument.aasm_states.should include(:valid)

    argument = Argument.new
    argument.invalid?.should be_true
    argument.aasm_current_state.should == :invalid

    argument.valid!
    argument.valid?.should be_true
    argument.aasm_current_state.should == :valid
  end
end

describe 'subclassing' do
  it 'should have the parent states' do
    Foo.aasm_states.each do |state|
      FooTwo.aasm_states.should include(state)
    end
    Baz.aasm_states.should == Bar.aasm_states
  end

  it 'should not add the child states to the parent machine' do
    Foo.aasm_states.should_not include(:foo)
  end

  it "should have the same events as its parent" do
    Baz.aasm_events.should == Bar.aasm_events
  end
end

describe :aasm_states_for_select do
  it "should return a select friendly array of states" do
    Foo.aasm_states_for_select.should == [['Open', 'open'], ['Closed', 'closed']]
  end
end

describe :aasm_from_states_for_state do
  it "should return all from states for a state" do
    froms = AuthMachine.aasm_from_states_for_state(:active)
    [:pending, :passive, :suspended].each {|from| froms.should include(from)}
  end

  it "should return from states for a state for a particular transition only" do
    froms = AuthMachine.aasm_from_states_for_state(:active, :transition => :unsuspend)
    [:suspended].each {|from| froms.should include(from)}
  end
end

describe 'instance methods' do
  let(:foo) {Foo.new}

  it 'should define a state querying instance method on including class' do
    foo.should respond_to(:open?)
    foo.should be_open
  end

  it 'should define an event! instance method' do
    foo.should respond_to(:close!)
    foo.close!
    foo.should be_closed
  end
end

describe AASM, '- initial states' do
  let(:foo) {Foo.new}
  let(:bar) {Bar.new}

  it 'should set the initial state' do
    foo.aasm_current_state.should == :open
    # foo.aasm.current_state.should == :open # not yet supported
    foo.should be_open
    foo.should_not be_closed
  end

  it 'should use the first state defined if no initial state is given' do
    bar.aasm_current_state.should == :read
    # bar.aasm.current_state.should == :read # not yet supported
  end

  it 'should determine initial state from the Proc results' do
    Banker.new(Banker::RICH - 1).aasm_current_state.should == :selling_bad_mortgages
    Banker.new(Banker::RICH + 1).aasm_current_state.should == :retired
  end
end

describe 'event firing without persistence' do
  it 'should attempt to persist if aasm_write_state is defined' do
    foo = Foo.new
    def foo.aasm_write_state; end

    foo.should_receive(:aasm_write_state_without_persistence).twice
    foo.close
  end
end

describe :aasm_events_for_current_state do
  let(:foo) {Foo.new}

  it 'work' do
    foo.aasm_events_for_current_state.should include(:close)
    foo.aasm_events_for_current_state.should include(:null)
    foo.close
    foo.aasm_events_for_current_state.should be_empty
  end
end


