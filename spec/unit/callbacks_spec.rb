require 'spec_helper'
Dir[File.dirname(__FILE__) + "/../models/callbacks/*.rb"].sort.each { |f| require File.expand_path(f) }

shared_examples 'an implemented callback that accepts error' do
  context 'with callback defined' do
    it "should run error_callback if an exception is raised and always return false" do
      aasm_model.class.send(:define_method, callback_name) do |e|
        @data = [e]
      end

      allow(aasm_model).to receive(:before_enter).and_raise(e = StandardError.new)

      expect(aasm_model.safe_close!).to be false
      expect(aasm_model.data).to eql [e]
    end

    it "should run error_callback without parameters if callback does not support any" do
      aasm_model.class.send(:define_method, callback_name) do |e|
        @data = []
      end

      allow(aasm_model).to receive(:before_enter).and_raise(e = StandardError.new)

      aasm_model.safe_close!('arg1', 'arg2')
      expect(aasm_model.data).to eql []
    end

    it "should run error_callback with parameters if callback supports them" do
      aasm_model.class.send(:define_method, callback_name) do |e, arg1, arg2|
        @data = [arg1, arg2]
      end

      allow(aasm_model).to receive(:before_enter).and_raise(e = StandardError.new)

      aasm_model.safe_close!('arg1', 'arg2')
      expect(aasm_model.data).to eql ['arg1', 'arg2']
    end
  end
end

shared_examples 'an implemented callback' do
  context 'with callback defined' do
    it 'should run callback without parameters if callback does not support any' do
      aasm_model.class.send(:define_method, callback_name) do
        @data = ['callback-was-called']
      end

      aasm_model.safe_close!
      expect(aasm_model.data).to eql ['callback-was-called']
    end

    it 'should run callback with parameters if callback supports them' do
      aasm_model.class.send(:define_method, callback_name) do |arg1, arg2|
        @data = [arg1, arg2]
      end

      aasm_model.safe_close!('arg1', 'arg2')
      expect(aasm_model.data).to eql ['arg1', 'arg2']
    end
  end
end

describe 'callbacks for the new DSL' do

  it "be called in order" do
    show_debug_log = false

    callback = Callbacks::Basic.new(:log => show_debug_log)
    callback.aasm.current_state

    unless show_debug_log
      expect(callback).to receive(:before_all_events).once.ordered
      expect(callback).to receive(:before_event).once.ordered
      expect(callback).to receive(:event_guard).once.ordered.and_return(true)
      expect(callback).to receive(:transition_guard).once.ordered.and_return(true)
      expect(callback).to receive(:before_exit_open).once.ordered                   # these should be before the state changes
      expect(callback).to receive(:exit_open).once.ordered
      # expect(callback).to receive(:event_guard).once.ordered.and_return(true)
      # expect(callback).to receive(:transition_guard).once.ordered.and_return(true)
      expect(callback).to receive(:after_all_transitions).once.ordered
      expect(callback).to receive(:after_transition).once.ordered
      expect(callback).to receive(:before_enter_closed).once.ordered
      expect(callback).to receive(:enter_closed).once.ordered
      expect(callback).to receive(:aasm_write_state).once.ordered.and_return(true)  # this is when the state changes
      expect(callback).to receive(:after_exit_open).once.ordered                    # these should be after the state changes
      expect(callback).to receive(:after_enter_closed).once.ordered
      expect(callback).to receive(:after_event).once.ordered
      expect(callback).to receive(:after_all_events).once.ordered
      expect(callback).to receive(:ensure_event).once.ordered
      expect(callback).to receive(:ensure_on_all_events).once.ordered
    end

    # puts "------- close!"
    callback.close!
  end


  it "works fine after reload" do
    show_debug_log = false

    callback = Callbacks::Basic.new(:log => show_debug_log)
    callback.aasm.current_state

    # reload the class
    Callbacks.send(:remove_const, :Basic)
    load 'models/callbacks/basic.rb'

    unless show_debug_log
      expect(callback).to receive(:before_event).once.ordered
      expect(callback).to receive(:event_guard).once.ordered.and_return(true)
      expect(callback).to receive(:transition_guard).once.ordered.and_return(true)
      expect(callback).to receive(:before_exit_open).once.ordered                    # these should be before the state changes
      expect(callback).to receive(:exit_open).once.ordered
      # expect(callback).to receive(:event_guard).once.ordered.and_return(true)
      # expect(callback).to receive(:transition_guard).once.ordered.and_return(true)
      expect(callback).to receive(:after_all_transitions).once.ordered
      expect(callback).to receive(:after_transition).once.ordered
      expect(callback).to receive(:before_enter_closed).once.ordered
      expect(callback).to receive(:enter_closed).once.ordered
      expect(callback).to receive(:aasm_write_state).once.ordered.and_return(true)   # this is when the state changes
      expect(callback).to receive(:event_before_success).once.ordered
      expect(callback).to receive(:success_transition).once.ordered.and_return(true) # these should be after the state changes
      expect(callback).to receive(:after_exit_open).once.ordered
      expect(callback).to receive(:after_enter_closed).once.ordered
      expect(callback).to receive(:after_event).once.ordered
    end

    # puts "------- close!"
    callback.close!
  end

  it "does not run any state callback if the event guard fails" do
    callback = Callbacks::Basic.new(:log => false)
    callback.aasm.current_state

    expect(callback).to receive(:before_all_events).once.ordered
    expect(callback).to receive(:before_event).once.ordered
    expect(callback).to receive(:event_guard).once.ordered.and_return(false)
    expect(callback).to_not receive(:transition_guard)
    expect(callback).to_not receive(:before_exit_open)
    expect(callback).to_not receive(:exit_open)
    expect(callback).to_not receive(:after_all_transitions)
    expect(callback).to_not receive(:after_transition)
    expect(callback).to_not receive(:before_enter_closed)
    expect(callback).to_not receive(:enter_closed)
    expect(callback).to_not receive(:aasm_write_state)
    expect(callback).to_not receive(:event_before_success)
    expect(callback).to_not receive(:success_transition)
    expect(callback).to_not receive(:after_exit_open)
    expect(callback).to_not receive(:after_enter_closed)
    expect(callback).to_not receive(:after_event)
    expect(callback).to_not receive(:after_all_events)
    expect(callback).to receive(:ensure_event).once.ordered
    expect(callback).to receive(:ensure_on_all_events).once.ordered

    expect {
      callback.close!
    }.to raise_error(AASM::InvalidTransition)
  end

  it "handles private callback methods as well" do
    show_debug_log = false

    callback = Callbacks::PrivateMethod.new(:log => show_debug_log)
    callback.aasm.current_state

    # puts "------- close!"
    expect {
      callback.close!
    }.to_not raise_error
  end

  context "if the transition guard fails" do
    it "does not run any state callback if guard is defined inline" do
      show_debug_log = false
      callback = Callbacks::Basic.new(:log => show_debug_log, :fail_transition_guard => true)
      callback.aasm.current_state

      unless show_debug_log
        expect(callback).to receive(:before_all_events).once.ordered
        expect(callback).to receive(:before_event).once.ordered
        expect(callback).to receive(:event_guard).once.ordered.and_return(true)
        expect(callback).to receive(:transition_guard).once.ordered.and_return(false)
        expect(callback).to_not receive(:before_exit_open)
        expect(callback).to_not receive(:exit_open)
        expect(callback).to_not receive(:after_all_transitions)
        expect(callback).to_not receive(:after_transition)
        expect(callback).to_not receive(:before_enter_closed)
        expect(callback).to_not receive(:enter_closed)
        expect(callback).to_not receive(:aasm_write_state)
        expect(callback).to_not receive(:event_before_success)
        expect(callback).to_not receive(:success_transition)
        expect(callback).to_not receive(:after_exit_open)
        expect(callback).to_not receive(:after_enter_closed)
        expect(callback).to_not receive(:after_event)
        expect(callback).to_not receive(:after_all_events)
        expect(callback).to receive(:ensure_event).once.ordered
        expect(callback).to receive(:ensure_on_all_events).once.ordered
      end

      expect {
        callback.close!
      }.to raise_error(AASM::InvalidTransition)
    end

    it "does not propagate failures to next attempt of same transition" do
      callback = Callbacks::Basic.new(:log => false, :fail_transition_guard => true)

      expect {
        callback.close!
      }.to raise_error(AASM::InvalidTransition, "Event 'close' cannot transition from 'open'. Failed callback(s): [:transition_guard].")

      expect {
        callback.close!
      }.to raise_error(AASM::InvalidTransition, "Event 'close' cannot transition from 'open'. Failed callback(s): [:transition_guard].")
    end

    it "does not propagate failures to next attempt of same event when no transition is applicable" do
      callback = Callbacks::Basic.new(:log => false, :fail_transition_guard => true)

      expect {
        callback.close!
      }.to raise_error(AASM::InvalidTransition, "Event 'close' cannot transition from 'open'. Failed callback(s): [:transition_guard].")

      callback.aasm.current_state = :closed

      expect {
        callback.close!
      }.to raise_error(AASM::InvalidTransition, "Event 'close' cannot transition from 'closed'.")
    end

    it "does not run transition_guard twice for multiple permitted transitions" do
      show_debug_log = false
      callback = Callbacks::MultipleTransitionsTransitionGuard.new(:log => show_debug_log, :fail_transition_guard => true)
      callback.aasm.current_state

      unless show_debug_log
        expect(callback).to receive(:before).once.ordered
        expect(callback).to receive(:event_guard).once.ordered.and_return(true)
        expect(callback).to receive(:transition_guard).once.ordered.and_return(false)
        expect(callback).to receive(:event_guard).once.ordered.and_return(true)
        expect(callback).to receive(:before_exit_open).once.ordered
        expect(callback).to receive(:exit_open).once.ordered
        expect(callback).to receive(:aasm_write_state).once.ordered.and_return(true)  # this is when the state changes
        expect(callback).to receive(:after_exit_open).once.ordered
        expect(callback).to receive(:after).once.ordered

        expect(callback).to_not receive(:transitioning)
        expect(callback).to_not receive(:event_before_success)
        expect(callback).to_not receive(:success_transition)
        expect(callback).to_not receive(:before_enter_closed)
        expect(callback).to_not receive(:enter_closed)
        expect(callback).to_not receive(:after_enter_closed)
      end

      callback.close!
      expect(callback.aasm.current_state).to eql :failed
    end

    it "does not run any state callback if guard is defined with block" do
      callback = Callbacks::GuardWithinBlock.new #(:log => true, :fail_transition_guard => true)
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
      expect(callback).to_not receive(:event_before_success)
      expect(callback).to_not receive(:success_transition)
      expect(callback).to_not receive(:after_exit_open)
      expect(callback).to_not receive(:after_enter_closed)
      expect(callback).to_not receive(:after)

      expect {
        callback.close!
      }.to raise_error(AASM::InvalidTransition)
    end
  end

  it "should properly pass arguments" do
    cb = Callbacks::WithArgs.new(:log => false)
    cb.aasm.current_state

    cb.reset_data
    cb.close!(:arg1, :arg2)
    expect(cb.data).to eql 'before(:arg1,:arg2) before_exit_open(:arg1,:arg2) transition_proc(:arg1,:arg2) before_enter_closed(:arg1,:arg2) aasm_write_state transition_success(:arg1,:arg2) after_exit_open(:arg1,:arg2) after_enter_closed(:arg1,:arg2) after(:arg1,:arg2)'
  end

  it "should call the callbacks given the to-state as argument" do
    cb = Callbacks::WithStateArg.new
    expect(cb).to receive(:before_method).with(:arg1).once.ordered
    expect(cb).to receive(:transition_method).never
    expect(cb).to receive(:success_method).never
    expect(cb).to receive(:transition_method2).with(:arg1).once.ordered
    expect(cb).to receive(:success_method2).with(:arg1).once.ordered
    expect(cb).to receive(:after_method).with(:arg1).once.ordered
    cb.close!(:out_to_lunch, :arg1)

    cb = Callbacks::WithStateArg.new
    some_object = double('some object')
    expect(cb).to receive(:before_method).with(some_object).once.ordered
    expect(cb).to receive(:transition_method2).with(some_object).once.ordered
    expect(cb).to receive(:success_method2).with(some_object).once.ordered
    expect(cb).to receive(:after_method).with(some_object).once.ordered
    cb.close!(:out_to_lunch, some_object)
  end

  it "should call the proper methods just with arguments" do
    cb = Callbacks::WithStateArg.new
    expect(cb).to receive(:before_method).with(:arg1).once.ordered
    expect(cb).to receive(:transition_method).with(:arg1).once.ordered
    expect(cb).to receive(:transition_method).never
    expect(cb).to receive(:success_method).with(:arg1).once.ordered
    expect(cb).to receive(:success_method).never
    expect(cb).to receive(:after_method).with(:arg1).once.ordered
    cb.close!(:arg1)

    cb = Callbacks::WithStateArg.new
    some_object = double('some object')
    expect(cb).to receive(:before_method).with(some_object).once.ordered
    expect(cb).to receive(:transition_method).with(some_object).once.ordered
    expect(cb).to receive(:transition_method).never
    expect(cb).to receive(:success_method).with(some_object).once.ordered
    expect(cb).to receive(:success_method).never
    expect(cb).to receive(:after_method).with(some_object).once.ordered
    cb.close!(some_object)
  end
end

describe 'event callbacks' do
  describe "with an error callback defined" do
    before do
      class Foo
        # this hack is needed to allow testing of parameters, since RSpec
        # destroys a method's arity when mocked
        attr_accessor :data

        aasm do
          event :safe_close, :success => :success_callback, :error => :error_callback do
            transitions :to => :closed, :from => [:open], :success => :transition_success_callback
          end
        end
      end

      @foo = Foo.new
    end

    it_behaves_like 'an implemented callback that accepts error' do
      let(:aasm_model) { @foo }
      let(:callback_name) { :error_callback }
    end

    it "should raise NoMethodError if exception is raised and error_callback is declared but not defined" do
      allow(@foo).to receive(:before_enter).and_raise(StandardError)
      expect{@foo.safe_close!}.to raise_error(NoMethodError)
    end

    it "should propagate an error if no error callback is declared" do
      allow(@foo).to receive(:before_enter).and_raise("Cannot enter safe")
      expect{@foo.close!}.to raise_error(StandardError, "Cannot enter safe")
    end
  end

  describe 'with an ensure callback defined' do
    before do
      class Foo
        # this hack is needed to allow testing of parameters, since RSpec
        # destroys a method's arity when mocked
        attr_accessor :data

        aasm do
          event :safe_close, :success => :success_callback, :ensure => :ensure_callback do
            transitions :to => :closed, :from => [:open]
          end
        end
      end

      @foo = Foo.new
    end

    it_behaves_like 'an implemented callback' do
      let(:aasm_model) { @foo }
      let(:callback_name) { :ensure_callback }
    end

    it "should raise NoMethodError if ensure_callback is declared but not defined" do
      expect{@foo.safe_close!}.to raise_error(NoMethodError)
    end

    it "should not raise any error if no ensure_callback is declared" do
      expect{@foo.close!}.to_not raise_error
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

describe 'global error_on_all_events_callback callbacks' do
  describe "with an error_on_all_events" do
    before do
      class FooGlobal
        # this hack is needed to allow testing of parameters, since RSpec
        # destroys a method's arity when mocked
        attr_accessor :data

        aasm do
          error_on_all_events  :error_on_all_events_callback

          event :safe_close do
            transitions :to => :closed, :from => [:open]
          end
        end
      end

      @foo = FooGlobal.new
    end

    it_behaves_like 'an implemented callback that accepts error' do
      let(:aasm_model) { @foo }
      let(:callback_name) { :error_on_all_events_callback }
    end

    it "should raise NoMethodError if exception is raised and error_callback is declared but not defined" do
      allow(@foo).to receive(:before_enter).and_raise(StandardError)
      expect{@foo.safe_close!}.to raise_error(NoMethodError)
    end

    it "should raise NoMethodError if no error callback is declared" do
      allow(@foo).to receive(:before_enter).and_raise("Cannot enter safe")
      expect{@foo.close!}.to raise_error(NoMethodError)
    end
  end
end

describe 'global ensure_on_all_events_callback callbacks' do
  describe "with an ensure_on_all_events" do
    before do
      class FooGlobal
        # this hack is needed to allow testing of parameters, since RSpec
        # destroys a method's arity when mocked
        attr_accessor :data

        aasm do
          ensure_on_all_events  :ensure_on_all_events_callback

          event :safe_close do
            transitions :to => :closed, :from => [:open]
          end
        end
      end

      @foo = FooGlobal.new
    end

    it_behaves_like 'an implemented callback' do
      let(:aasm_model) { @foo }
      let(:callback_name) { :ensure_on_all_events_callback }
    end

    it "should raise NoMethodError if ensure_on_all_events callback is declared but not defined" do
      expect{@foo.safe_close!}.to raise_error(NoMethodError)
    end

    it "should raise NoMethodError if no ensure_on_all_events callback is declared" do
      expect{@foo.close!}.to raise_error(NoMethodError)
    end
  end
end
