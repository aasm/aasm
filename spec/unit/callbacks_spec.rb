require 'spec_helper'

describe 'callbacks for the new DSL' do

  it "be called in order" do
    callback = CallbackNewDsl.new
    callback.aasm.current_state

    expect(callback).to receive(:before).once.ordered
    expect(callback).to receive(:event_guard).once.ordered.and_return(true)
    expect(callback).to receive(:transition_guard).once.ordered.and_return(true)
    expect(callback).to receive(:before_exit_open).once.ordered                   # these should be before the state changes
    expect(callback).to receive(:exit_open).once.ordered
    # expect(callback).to receive(:event_guard).once.ordered.and_return(true)
    # expect(callback).to receive(:transition_guard).once.ordered.and_return(true)
    expect(callback).to receive(:transitioning).once.ordered
    expect(callback).to receive(:before_enter_closed).once.ordered
    expect(callback).to receive(:enter_closed).once.ordered
    expect(callback).to receive(:aasm_write_state).once.ordered.and_return(true)  # this is when the state changes
    expect(callback).to receive(:after_exit_open).once.ordered                    # these should be after the state changes
    expect(callback).to receive(:after_enter_closed).once.ordered
    expect(callback).to receive(:after).once.ordered

    # puts "------- close!"
    callback.close!
  end

  it "does not run any state callback if the event guard fails" do
    callback = CallbackNewDsl.new(:log => false)
    callback.aasm.current_state

    expect(callback).to receive(:before).once.ordered
    expect(callback).to receive(:event_guard).once.ordered.and_return(false)
    expect(callback).to_not receive(:transition_guard)
    expect(callback).to_not receive(:before_exit_open)
    expect(callback).to_not receive(:exit_open)
    expect(callback).to_not receive(:transitioning)
    expect(callback).to_not receive(:before_enter_closed)
    expect(callback).to_not receive(:enter_closed)
    expect(callback).to_not receive(:aasm_write_state)
    expect(callback).to_not receive(:after_exit_open)
    expect(callback).to_not receive(:after_enter_closed)
    expect(callback).to_not receive(:after)

    expect {
      callback.close!
    }.to raise_error(AASM::InvalidTransition)
  end

  it "does not run any state callback if the transition guard fails" do
    callback = CallbackNewDsl.new
    callback.aasm.current_state

    expect(callback).to receive(:before).once.ordered
    expect(callback).to receive(:event_guard).once.ordered.and_return(true)
    expect(callback).to receive(:transition_guard).once.ordered.and_return(false)
    expect(callback).to_not receive(:before_exit_open)
    expect(callback).to_not receive(:exit_open)
    expect(callback).to_not receive(:transitioning)
    expect(callback).to_not receive(:before_enter_closed)
    expect(callback).to_not receive(:enter_closed)
    expect(callback).to_not receive(:aasm_write_state)
    expect(callback).to_not receive(:after_exit_open)
    expect(callback).to_not receive(:after_enter_closed)
    expect(callback).to_not receive(:after)

    expect {
      callback.close!
    }.to raise_error(AASM::InvalidTransition)
  end

  it "should properly pass arguments" do
    cb = CallbackNewDslArgs.new

    # TODO: use expect syntax here
    cb.should_receive(:before).with(:arg1, :arg2).once.ordered
    cb.should_receive(:before_exit_open).once.ordered                   # these should be before the state changes
    cb.should_receive(:transition_proc).with(:arg1, :arg2).once.ordered
    cb.should_receive(:before_enter_closed).once.ordered
    cb.should_receive(:aasm_write_state).once.ordered.and_return(true)  # this is when the state changes
    cb.should_receive(:after_exit_open).once.ordered                    # these should be after the state changes
    cb.should_receive(:after_enter_closed).once.ordered
    cb.should_receive(:after).with(:arg1, :arg2).once.ordered

    cb.close!(:arg1, :arg2)
  end

  it "should call the callbacks given the to-state as argument" do
    cb = CallbackWithStateArg.new
    cb.should_receive(:before_method).with(:arg1).once.ordered
    cb.should_receive(:transition_method).never
    cb.should_receive(:transition_method2).with(:arg1).once.ordered
    cb.should_receive(:after_method).with(:arg1).once.ordered
    cb.close!(:out_to_lunch, :arg1)

    cb = CallbackWithStateArg.new
    some_object = double('some object')
    cb.should_receive(:before_method).with(some_object).once.ordered
    cb.should_receive(:transition_method2).with(some_object).once.ordered
    cb.should_receive(:after_method).with(some_object).once.ordered
    cb.close!(:out_to_lunch, some_object)
  end

  it "should call the proper methods just with arguments" do
    cb = CallbackWithStateArg.new
    cb.should_receive(:before_method).with(:arg1).once.ordered
    cb.should_receive(:transition_method).with(:arg1).once.ordered
    cb.should_receive(:transition_method).never
    cb.should_receive(:after_method).with(:arg1).once.ordered
    cb.close!(:arg1)

    cb = CallbackWithStateArg.new
    some_object = double('some object')
    cb.should_receive(:before_method).with(some_object).once.ordered
    cb.should_receive(:transition_method).with(some_object).once.ordered
    cb.should_receive(:transition_method).never
    cb.should_receive(:after_method).with(some_object).once.ordered
    cb.close!(some_object)
  end
end

describe 'event callbacks' do
  describe "with an error callback defined" do
    before do
      class Foo
        aasm do
          event :safe_close, :success => :success_callback, :error => :error_callback do
            transitions :to => :closed, :from => [:open]
          end
        end
      end

      @foo = Foo.new
    end

    it "should run error_callback if an exception is raised and error_callback defined" do
      def @foo.error_callback(e); end

      allow(@foo).to receive(:before_enter).and_raise(e=StandardError.new)
      expect(@foo).to receive(:error_callback).with(e)

      @foo.safe_close!
    end

    it "should raise NoMethodError if exceptionis raised and error_callback is declared but not defined" do
      allow(@foo).to receive(:before_enter).and_raise(StandardError)
      expect{@foo.safe_close!}.to raise_error(NoMethodError)
    end

    it "should propagate an error if no error callback is declared" do
        allow(@foo).to receive(:before_enter).and_raise("Cannot enter safe")
        expect{@foo.close!}.to raise_error(StandardError, "Cannot enter safe")
    end
  end

  describe "with aasm_event_fired defined" do
    before do
      @foo = Foo.new
      def @foo.aasm_event_fired(event, from, to); end
    end

    it 'should call it for successful bang fire' do
      expect(@foo).to receive(:aasm_event_fired).with(:close, :open, :closed)
      @foo.close!
    end

    it 'should call it for successful non-bang fire' do
      expect(@foo).to receive(:aasm_event_fired)
      @foo.close
    end

    it 'should not call it for failing bang fire' do
      allow(@foo.aasm).to receive(:set_current_state_with_persistence).and_return(false)
      expect(@foo).not_to receive(:aasm_event_fired)
      @foo.close!
    end
  end

  describe "with aasm_event_failed defined" do
    before do
      @foo = Foo.new
      def @foo.aasm_event_failed(event, from); end
    end

    it 'should call it when transition failed for bang fire' do
      expect(@foo).to receive(:aasm_event_failed).with(:null, :open)
      expect {@foo.null!}.to raise_error(AASM::InvalidTransition)
    end

    it 'should call it when transition failed for non-bang fire' do
      expect(@foo).to receive(:aasm_event_failed).with(:null, :open)
      expect {@foo.null}.to raise_error(AASM::InvalidTransition)
    end

    it 'should not call it if persist fails for bang fire' do
      allow(@foo.aasm).to receive(:set_current_state_with_persistence).and_return(false)
      expect(@foo).to receive(:aasm_event_failed)
      @foo.close!
    end
  end
end
