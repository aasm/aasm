require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

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

describe "naming" do
  it "work for valid" do
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
  it 'should update the current state' do
    foo = Foo.new
    foo.close

    foo.aasm_current_state.should == :closed
  end

  it 'should attempt to persist if aasm_write_state is defined' do
    foo = Foo.new

    def foo.aasm_write_state
    end

    foo.should_receive(:aasm_write_state_without_persistence).twice

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
  describe "with an error callback defined" do
    before do
      class Foo
        aasm_event :safe_close, :success => :success_callback, :error => :error_callback do
          transitions :to => :closed, :from => [:open]
        end
      end

      @foo = Foo.new
    end

    it "should run error_callback if an exception is raised and error_callback defined" do
      def @foo.error_callback(e)
      end
      @foo.stub!(:enter).and_raise(e=StandardError.new)
      @foo.should_receive(:error_callback).with(e)
      @foo.safe_close!
    end

    it "should raise NoMethodError if exceptionis raised and error_callback is declared but not defined" do
      @foo.stub!(:enter).and_raise(StandardError)
      lambda{@foo.safe_close!}.should raise_error(NoMethodError)
    end

    it "should propagate an error if no error callback is declared" do
        @foo.stub!(:enter).and_raise("Cannot enter safe")
        lambda{@foo.close!}.should raise_error(StandardError, "Cannot enter safe")
    end
  end

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
      @foo.stub!(:aasm_set_current_state_with_persistence).and_return(false)
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
      lambda {@foo.null!}.should raise_error(AASM::InvalidTransition)
    end

    it 'should call it when transition failed for non-bang fire' do
      @foo.should_receive(:aasm_event_failed).with(:null, :open)
      lambda {@foo.null}.should raise_error(AASM::InvalidTransition)
    end

    it 'should not call it if persist fails for bang fire' do
      @foo.stub!(:aasm_set_current_state_with_persistence).and_return(false)
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

  it 'should call on_transition with an array of methods' do
    cp = ChetanPatil.new
    cp.wakeup! :showering
    cp.should_receive(:condition_hair)
    cp.should_receive(:fix_hair)
    cp.dress!(:prettying_up)
  end
end
