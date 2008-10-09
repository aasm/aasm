require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe AASM::SupportingClasses::Event do
  before(:each) do
    @name = :close_order
    @success = :success_callback
  end

  def new_event
    @event = AASM::SupportingClasses::Event.new(@name, {:success => @success}) do
      transitions :to => :closed, :from => [:open, :received]
    end
  end

  it 'should set the name' do
    new_event
    @event.name.should == @name
  end

  it 'should set the success option' do
    new_event
    @event.success.should == @success
  end

  it 'should create StateTransitions' do
    AASM::SupportingClasses::StateTransition.should_receive(:new).with({:to => :closed, :from => :open})
    AASM::SupportingClasses::StateTransition.should_receive(:new).with({:to => :closed, :from => :received})
    new_event
  end
end

describe AASM::SupportingClasses::Event, 'when firing an event' do
  it 'should raise an AASM::InvalidTransition error if the transitions are empty' do
    obj = mock('object')
    obj.stub!(:aasm_current_state)

    event = AASM::SupportingClasses::Event.new(:event)
    lambda { event.fire(obj) }.should raise_error(AASM::InvalidTransition)
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

describe AASM::SupportingClasses::Event, 'when executing the success callback' do
  class ThisNameBetterNotBeInUse
    include AASM

    aasm_state :initial
    aasm_state :symbol
    aasm_state :string
    aasm_state :array
    aasm_state :proc
  end

  it "should send the success callback if it's a symbol" do
    ThisNameBetterNotBeInUse.instance_eval {
      aasm_event :with_symbol, :success => :symbol_success_callback do
        transitions :to => :symbol, :from => [:initial]
      end
    }

    model = ThisNameBetterNotBeInUse.new
    model.should_receive(:symbol_success_callback)
    model.with_symbol!
  end

  it "should send the success callback if it's a string" do
    ThisNameBetterNotBeInUse.instance_eval {
      aasm_event :with_string, :success => 'string_success_callback' do
        transitions :to => :string, :from => [:initial]
      end
    }

    model = ThisNameBetterNotBeInUse.new
    model.should_receive(:string_success_callback)
    model.with_string!
  end

  it "should call each success callback if passed an array of strings and/or symbols" do
    ThisNameBetterNotBeInUse.instance_eval {
      aasm_event :with_array, :success => [:success_callback1, 'success_callback2'] do
        transitions :to => :array, :from => [:initial]
      end
    }

    model = ThisNameBetterNotBeInUse.new
    model.should_receive(:success_callback1)
    model.should_receive(:success_callback2)
    model.with_array!
  end

  it "should call the success callback if it's a proc" do
    ThisNameBetterNotBeInUse.instance_eval {
      aasm_event :with_proc, :success => lambda { |obj| obj.proc_success_callback } do
        transitions :to => :proc, :from => [:initial]
      end
    }

    model = ThisNameBetterNotBeInUse.new
    model.should_receive(:proc_success_callback)
    model.with_proc!
  end
end
