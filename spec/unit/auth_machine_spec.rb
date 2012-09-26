require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe 'AuthMachine on initialization' do
  before(:each) do
    @auth = AuthMachine.new
  end

  it 'should be in the pending state' do
    @auth.aasm_current_state.should == :pending
  end

  it 'should have an activation code' do
    @auth.has_activation_code?.should be_true
    @auth.activation_code.should_not be_nil
  end
end

describe 'AuthMachine when being unsuspended' do
  it 'should be able to be unsuspended' do
    @auth = AuthMachine.new
    @auth.activate!
    @auth.suspend!
    @auth.may_unsuspend?.should be_true
  end
  
  it 'should not be able to be unsuspended into active' do
    @auth = AuthMachine.new
    @auth.suspend!
    @auth.may_unsuspend?(:active).should_not be_true
  end

  it 'should be able to be unsuspended into active if polite' do
    @auth = AuthMachine.new
    @auth.suspend!
    @auth.may_unsuspend?(:active, :please).should be_true
  end
  
  it 'should not be able to be unpassified' do
    @auth = AuthMachine.new
    @auth.activate!
    @auth.suspend!
    @auth.unsuspend!
    
    @auth.may_unpassify?.should_not be_true
  end
  
  it 'should be active if previously activated' do
    @auth = AuthMachine.new
    @auth.activate!
    @auth.suspend!
    @auth.unsuspend!

    @auth.aasm_current_state.should == :active
  end

  it 'should be pending if not previously activated, but an activation code is present' do
    @auth = AuthMachine.new
    @auth.suspend!
    @auth.unsuspend!

    @auth.aasm_current_state.should == :pending
  end

  it 'should be passive if not previously activated and there is no activation code' do
    @auth = AuthMachine.new
    @auth.activation_code = nil
    @auth.suspend!
    @auth.unsuspend!

    @auth.aasm_current_state.should == :passive
  end
end
