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

class FooTwo < Foo
  include AASM
  aasm_state :foo
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

class Banker
  include AASM
  aasm_initial_state  Proc.new { |banker| banker.rich? ? :retired : :selling_bad_mortgages }
  aasm_state          :retired
  aasm_state          :selling_bad_mortgages
  RICH = 1_000_000
  attr_accessor :balance
  def initialize(balance = 0); self.balance = balance; end
  def rich?; self.balance >= RICH; end
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
  it 'should have the parent states' do
    Foo.aasm_states.each do |state|
      FooTwo.aasm_states.should include(state)
    end
  end
  
  it 'should not add the child states to the parent machine' do
    Foo.aasm_states.should_not include(:foo)
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

  it 'should determine initial state from the Proc results' do
    Banker.new(Banker::RICH - 1).aasm_current_state.should == :selling_bad_mortgages
    Banker.new(Banker::RICH + 1).aasm_current_state.should == :retired
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
  describe "with aasm_event_fired defined" do
    before do
      @foo = Foo.new
      def @foo.aasm_event_fired(event, from, to)
      end
    end

    it 'should call it for successful bang fire' do
      @foo.should_receive(:aasm_event_fired).with(:close, :open, :closed)
      @foo.close!
    end

    it 'should call it for successful non-bang fire' do
      @foo.should_receive(:aasm_event_fired)
      @foo.close
    end

    it 'should not call it for failing bang fire' do
      @foo.stub!(:set_aasm_current_state_with_persistence).and_return(false)
      @foo.should_not_receive(:aasm_event_fired)
      @foo.close!
    end
  end

  describe "with aasm_event_failed defined" do
    before do
      @foo = Foo.new
      def @foo.aasm_event_failed(event, from)
      end
    end

    it 'should call it when transition failed for bang fire' do
      @foo.should_receive(:aasm_event_failed).with(:null, :open)
      @foo.null!
    end

    it 'should call it when transition failed for non-bang fire' do
      @foo.should_receive(:aasm_event_failed).with(:null, :open)
      @foo.null
    end

    it 'should not call it if persist fails for bang fire' do
      @foo.stub!(:set_aasm_current_state_with_persistence).and_return(false)
      @foo.should_receive(:aasm_event_failed)
      @foo.close!
    end
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
