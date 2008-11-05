require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class Foo
  include AASM
  aasm_initial_state :open
  aasm_state :open, :exit => :exit
  aasm_state :closed, :enter => :enter

  aasm_event :close, :success => :success_callback do
    transitions :to => :closed, :from => [:open]
  end

  aasm_event :null do
    transitions :to => :closed, :from => [:open], :guard => :always_false
  end

  def always_false
    false
  end

  def success_callback
  end

  def enter
  end
  def exit
  end
end

class Bar
  include AASM

  aasm_state :read
  aasm_state :ended

  aasm_event :foo do
    transitions :to => :ended, :from => [:read]
  end
end

class Baz < Bar
end


describe AASM, '- class level definitions' do
  it 'should define a class level aasm_initial_state() method on its including class' do
    Foo.should respond_to(:aasm_initial_state)
  end

  it 'should define a class level aasm_state() method on its including class' do
    Foo.should respond_to(:aasm_state)
  end

  it 'should define a class level aasm_event() method on its including class' do
    Foo.should respond_to(:aasm_event)
  end
  
  it 'should define a class level aasm_states() method on its including class' do
    Foo.should respond_to(:aasm_states)
  end
  
  it 'should define a class level aasm_states_for_select() method on its including class' do
    Foo.should respond_to(:aasm_states_for_select)
  end

  it 'should define a class level aasm_events() method on its including class' do
    Foo.should respond_to(:aasm_events)
  end

end


describe AASM, '- subclassing' do
  before(:each) do
    @parent = Class.new do
      include AASM
    end
  end

  it 'should invoke the original inherited callback' do
    @parent.should_receive(:inherited)
    Class.new(@parent)
  end

  it 'should have a unique states hash' do
    child = Class.new(@parent)
    child.aasm_states.equal?(@parent.aasm_states).should be_false
  end
end


describe AASM, '- aasm_states_for_select' do
  it "should return a select friendly array of states in the form of [['Friendly name', 'state_name']]" do
    Foo.aasm_states_for_select.should == [['Open', 'open'], ['Closed', 'closed']]
  end
end

describe AASM, '- instance level definitions' do
  before(:each) do
    @foo = Foo.new
  end

  it 'should define a state querying instance method on including class' do
    @foo.should respond_to(:open?)
  end

  it 'should define an event! inance method' do
    @foo.should respond_to(:close!)
  end
end

describe AASM, '- initial states' do
  before(:each) do
    @foo = Foo.new
    @bar = Bar.new
  end

  it 'should set the initial state' do
    @foo.aasm_current_state.should == :open
  end

  it '#open? should be initially true' do
    @foo.open?.should be_true
  end

  it '#closed? should be initially false' do
    @foo.closed?.should be_false
  end

  it 'should use the first state defined if no initial state is given' do
    @bar.aasm_current_state.should == :read
  end
end

describe AASM, '- event firing with persistence' do
  it 'should fire the Event' do
    foo = Foo.new

    Foo.aasm_events[:close].should_receive(:fire).with(foo)
    foo.close!
  end

  it 'should update the current state' do
    foo = Foo.new
    foo.close!

    foo.aasm_current_state.should == :closed
  end

  it 'should call the success callback if one was provided' do
    foo = Foo.new

    foo.should_receive(:success_callback)

    foo.close!
  end

  it 'should attempt to persist if aasm_write_state is defined' do
    foo = Foo.new
    
    def foo.aasm_write_state
    end

    foo.should_receive(:aasm_write_state)

    foo.close!
  end

  it 'should return true if aasm_write_state is defined and returns true' do
    foo = Foo.new
    
    def foo.aasm_write_state(state)
      true
    end

    foo.close!.should be_true
  end

  it 'should return false if aasm_write_state is defined and returns false' do
    foo = Foo.new
    
    def foo.aasm_write_state(state)
      false
    end

    foo.close!.should be_false
  end

  it "should not update the aasm_current_state if the write fails" do
    foo = Foo.new
    
    def foo.aasm_write_state
      false
    end

    foo.should_receive(:aasm_write_state)

    foo.close!
    foo.aasm_current_state.should == :open
  end
end

describe AASM, '- event firing without persistence' do
  it 'should fire the Event' do
    foo = Foo.new

    Foo.aasm_events[:close].should_receive(:fire).with(foo)
    foo.close
  end

  it 'should update the current state' do
    foo = Foo.new
    foo.close

    foo.aasm_current_state.should == :closed
  end

  it 'should attempt to persist if aasm_write_state is defined' do
    foo = Foo.new
    
    def foo.aasm_write_state
    end

    foo.should_receive(:aasm_write_state_without_persistence)

    foo.close
  end
end

describe AASM, '- persistence' do
  it 'should read the state if it has not been set and aasm_read_state is defined' do
    foo = Foo.new
    def foo.aasm_read_state
    end

    foo.should_receive(:aasm_read_state)

    foo.aasm_current_state
  end
end

describe AASM, '- getting events for a state' do
  it '#aasm_events_for_current_state should use current state' do
    foo = Foo.new
    foo.should_receive(:aasm_current_state)
    foo.aasm_events_for_current_state
  end

  it '#aasm_events_for_current_state should use aasm_events_for_state' do
    foo = Foo.new
    foo.stub!(:aasm_current_state).and_return(:foo)
    foo.should_receive(:aasm_events_for_state).with(:foo)
    foo.aasm_events_for_current_state
  end
end

describe AASM, '- event callbacks' do
  it 'should call aasm_event_fired if defined and successful for bang fire' do
    foo = Foo.new
    def foo.aasm_event_fired(from, to)
    end

    foo.should_receive(:aasm_event_fired)

    foo.close!
  end

  it 'should not call aasm_event_fired if defined but persist fails for bang fire' do
    foo = Foo.new
    def foo.aasm_event_fired(from, to)
    end
    foo.stub!(:set_aasm_current_state_with_persistence).and_return(false)

    foo.should_not_receive(:aasm_event_fired)

    foo.close!
  end

  it 'should not call aasm_event_failed if defined and persist fails for bang fire' do
    foo = Foo.new
    def foo.aasm_event_failed(from, to)
    end
    foo.stub!(:set_aasm_current_state_with_persistence).and_return(false)

    foo.should_receive(:aasm_event_failed)

    foo.close!
  end

  it 'should call aasm_event_fired if defined and successful for non-bang fire' do
    foo = Foo.new
    def foo.aasm_event_fired(from, to)
    end

    foo.should_receive(:aasm_event_fired)

    foo.close
  end

  it 'should call aasm_event_failed if defined and transition failed for bang fire' do
    foo = Foo.new
    def foo.aasm_event_failed(event)
    end

    foo.should_receive(:aasm_event_failed)

    foo.null!
  end

  it 'should call aasm_event_failed if defined and transition failed for non-bang fire' do
    foo = Foo.new
    def foo.aasm_event_failed(event)
    end

    foo.should_receive(:aasm_event_failed)

    foo.null
  end
end

describe AASM, '- state actions' do
  it "should call enter when entering state" do
    foo = Foo.new
    foo.should_receive(:enter)

    foo.close
  end

  it "should call exit when exiting state" do
    foo = Foo.new
    foo.should_receive(:exit)

    foo.close
  end
end


describe Baz do
  it "should have the same states as it's parent" do
    Baz.aasm_states.should == Bar.aasm_states
  end

  it "should have the same events as it's parent" do
    Baz.aasm_events.should == Bar.aasm_events
  end
end


class ChetanPatil
  include AASM
  aasm_initial_state :sleeping
  aasm_state :sleeping
  aasm_state :showering
  aasm_state :working
  aasm_state :dating

  aasm_event :wakeup do
    transitions :from => :sleeping, :to => [:showering, :working]
  end

  aasm_event :dress do
    transitions :from => :sleeping, :to => :working, :on_transition => :wear_clothes
    transitions :from => :showering, :to => [:working, :dating], :on_transition => Proc.new { |obj, *args| obj.wear_clothes(*args) }
  end

  def wear_clothes(shirt_color, trouser_type)
  end
end


describe ChetanPatil do
  it 'should transition to specified next state (sleeping to showering)' do
    cp = ChetanPatil.new
    cp.wakeup! :showering
    
    cp.aasm_current_state.should == :showering
  end

  it 'should transition to specified next state (sleeping to working)' do
    cp = ChetanPatil.new
    cp.wakeup! :working

    cp.aasm_current_state.should == :working
  end

  it 'should transition to default (first or showering) state' do
    cp = ChetanPatil.new
    cp.wakeup!

    cp.aasm_current_state.should == :showering
  end

  it 'should transition to default state when on_transition invoked' do
    cp = ChetanPatil.new
    cp.dress!(nil, 'purple', 'dressy')

    cp.aasm_current_state.should == :working
  end

  it 'should call on_transition method with args' do
    cp = ChetanPatil.new
    cp.wakeup! :showering

    cp.should_receive(:wear_clothes).with('blue', 'jeans')
    cp.dress! :working, 'blue', 'jeans'
  end

  it 'should call on_transition proc' do
    cp = ChetanPatil.new
    cp.wakeup! :showering

    cp.should_receive(:wear_clothes).with('purple', 'slacks')
    cp.dress!(:dating, 'purple', 'slacks')
  end
end
