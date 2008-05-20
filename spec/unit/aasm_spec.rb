require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class Foo
  include AASM
  aasm_initial_state :open
  aasm_state :open
  aasm_state :closed

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
end

class Bar
  include AASM
  aasm_state :read
  aasm_state :ended
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


describe AASM, '- aasm_states_for_select' do
  it "should return a select friendly array of states in the form of [['Friendly name', :state_name]]" do
    Foo.aasm_states_for_select.should == [['Open', :open], ['Closed', :closed]]
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
  it 'should call aasm_event_fired if defined and successful' do
    foo = Foo.new
    def foo.aasm_event_fired(from, to)
    end

    foo.should_receive(:aasm_event_fired)

    foo.close!
  end

  it 'should call aasm_event_failed if defined and transition failed' do
    foo = Foo.new
    def foo.aasm_event_failed(event)
    end

    foo.should_receive(:aasm_event_failed)

    foo.null!
  end
end


