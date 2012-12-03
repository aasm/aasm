require 'spec_helper'

describe 'subclassing' do
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
end

