require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class Foo
  include AASM
  aasm_initial_state :open
  aasm_state :open
  aasm_state :closed

  aasm_event :close do
    transitions :to => :closed, :from => [:open]
  end
end

class Bar
  include AASM
  aasm_state :read
  aasm_state :ended
end


describe AASM, '- class level definitions' do
  it 'should define a class level initial_state() method on its including class' do
    Foo.should respond_to(:aasm_initial_state)
  end

  it 'should define a class level state() method on its including class' do
    Foo.should respond_to(:aasm_state)
  end

  it 'should define a class level event() method on its including class' do
    Foo.should respond_to(:aasm_event)
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

describe AASM, '- event firing' do
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

  it 'should attempt to persist if aasm_write_state is defined' do
    foo = Foo.new
    
    def foo.aasm_write_state
    end

    foo.should_receive(:aasm_write_state)

    foo.close!
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
