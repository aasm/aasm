require File.join(File.dirname(__FILE__), '..', 'lib', 'event')

describe AASM::SupportingClasses::Event do
  before(:each) do
    @name = :close_order
  end

  def new_event
    @event = AASM::SupportingClasses::Event.new(@name) do
      transitions :to => :closed, :from => [:open, :received]
    end
  end

  it 'should set the name' do
    new_event
    @event.name.should == @name
  end

  it 'should create StateTransitions' do
    AASM::SupportingClasses::StateTransition.should_receive(:new).with({:to => :closed, :from => :open})
    AASM::SupportingClasses::StateTransition.should_receive(:new).with({:to => :closed, :from => :received})
    new_event
  end
end

describe AASM::SupportingClasses::Event, 'when firing an event' do
  it 'should raise an AASM::InvalidTransition error if the transitions are empty' do
    event = AASM::SupportingClasses::Event.new(:event)

    lambda { event.fire(nil) }.should raise_error(AASM::InvalidTransition)
  end

  it 'should return the state of the first matching transition it finds' do
    event = AASM::SupportingClasses::Event.new(:event) do
      transitions :to => :closed, :from => [:open, :received]
    end

    obj = mock('object')
    obj.stub!(:aasm_current_state).and_return(:open)

    event.fire(obj).should == :closed
  end
end
