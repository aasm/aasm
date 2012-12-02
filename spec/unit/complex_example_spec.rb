require 'spec_helper'

describe 'on initialization' do
  let(:auth) {AuthMachine.new}

  it 'should be in the pending state' do
    auth.aasm_current_state.should == :pending
  end

  it 'should have an activation code' do
    auth.has_activation_code?.should be_true
    auth.activation_code.should_not be_nil
  end
end

describe 'when being unsuspended' do
  let(:auth) {AuthMachine.new}

  it 'should be able to be unsuspended' do
    auth.activate!
    auth.suspend!
    auth.may_unsuspend?.should be_true
  end

  it 'should not be able to be unsuspended into active' do
    auth.suspend!
    auth.may_unsuspend?(:active).should_not be_true
  end

  it 'should be able to be unsuspended into active if polite' do
    auth.suspend!
    auth.may_wait?(:waiting, :please).should be_true
    auth.wait!(nil, :please)
  end

  it 'should not be able to be unsuspended into active if not polite' do
    auth.suspend!
    auth.may_wait?(:waiting).should_not be_true
    auth.may_wait?(:waiting, :rude).should_not be_true
    lambda {auth.wait!(nil, :rude)}.should raise_error(AASM::InvalidTransition)
    lambda {auth.wait!}.should raise_error(AASM::InvalidTransition)
  end

  it 'should not be able to be unpassified' do
    auth.activate!
    auth.suspend!
    auth.unsuspend!

    auth.may_unpassify?.should_not be_true
    lambda {auth.unpassify!}.should raise_error(AASM::InvalidTransition)
  end

  it 'should be active if previously activated' do
    auth.activate!
    auth.suspend!
    auth.unsuspend!

    auth.aasm_current_state.should == :active
  end

  it 'should be pending if not previously activated, but an activation code is present' do
    auth.suspend!
    auth.unsuspend!

    auth.aasm_current_state.should == :pending
  end

  it 'should be passive if not previously activated and there is no activation code' do
    auth.activation_code = nil
    auth.suspend!
    auth.unsuspend!

    auth.aasm_current_state.should == :passive
  end
end
