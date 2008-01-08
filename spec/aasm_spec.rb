require File.join(File.dirname(__FILE__), '..', 'lib', 'aasm')
require File.join(File.dirname(__FILE__), '..', 'lib', 'state')
require File.join(File.dirname(__FILE__), '..', 'lib', 'state_factory')

class Foo
  include AASM
  initial_state :open
  state :open
  state :closed

  event :close do
  end
end

class Bar
  include AASM
  state :read
  state :ended
end


describe AASM, '- class level definitions' do
  it 'should define a class level initial_state() method on its including class' do
    Foo.should respond_to(:initial_state)
  end

  it 'should define a class level state() method on its including class' do
    Foo.should respond_to(:state)
  end

  it 'should define a class level event() method on its including class' do
    Foo.should respond_to(:event)
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

  # TODO This isn't necessarily "in play" just yet
  #it 'using the state macro should create a new State object' do
  #  AASM::SupportingClasses::State.should_receive(:new).with(:open, {})
  #  Foo.state :open
  #end
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
