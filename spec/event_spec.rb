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

  it 'create StateTransitions' do
    AASM::SupportingClasses::StateTransition.should_receive(:new).with({:to => :closed, :from => :open})
    AASM::SupportingClasses::StateTransition.should_receive(:new).with({:to => :closed, :from => :received})
    new_event
  end

#  it 'should return an array of the next possible transitions for a state' do
#    new_event
#    @event.next_states(:open).size.should == 1
#    @event.next_states(:received).size.should == 1
#  end

#  it '#fire should run #perform on each state transition' do
#    st = mock('StateTransition')
#    st.should_receive(:perform)
#
#    new_event
#
#    @event.stub!(:next_states).and_return([st])
#    @event.fire(:closed)
#  end
end

