require 'spec_helper'

describe 'instance methods' do
  let(:foo) {Foo.new}

  it 'should define a state querying instance method on including class' do
    foo.should respond_to(:open?)
    foo.should be_open
  end

  it 'should define an event! instance method' do
    foo.should respond_to(:close!)
    foo.close!
    foo.should be_closed
  end
end

describe AASM, '- initial states' do
  let(:foo) {Foo.new}
  let(:bar) {Bar.new}

  it 'should set the initial state' do
    foo.aasm_current_state.should == :open
    # foo.aasm.current_state.should == :open # not yet supported
    foo.should be_open
    foo.should_not be_closed
  end

  it 'should use the first state defined if no initial state is given' do
    bar.aasm_current_state.should == :read
    # bar.aasm.current_state.should == :read # not yet supported
  end

  it 'should determine initial state from the Proc results' do
    Banker.new(Banker::RICH - 1).aasm_current_state.should == :selling_bad_mortgages
    Banker.new(Banker::RICH + 1).aasm_current_state.should == :retired
  end
end

describe 'event firing without persistence' do
  it 'should attempt to persist if aasm_write_state is defined' do
    foo = Foo.new
    def foo.aasm_write_state; end

    foo.should_receive(:aasm_write_state_without_persistence).twice
    foo.close
  end
end

