require 'spec_helper'

describe 'subclassing' do
  let(:son) {Son.new}

  it 'should have the parent states' do
    Foo.aasm_states.each do |state|
      FooTwo.aasm_states.should include(state)
    end
    Baz.aasm_states.should == Bar.aasm_states
  end

  it 'should not add the child states to the parent machine' do
    Foo.aasm_states.should_not include(:foo)
  end

  it "should have the same events as its parent" do
    Baz.aasm_events.should == Bar.aasm_events
  end

  it 'should know how to respond to `may_add_details?`' do
    son.may_add_details?.should be_true
  end

  it 'should not break if I call Son#update_state' do
    son.update_state
    son.aasm_current_state.should == :pending_details_confirmation
  end
  
end

