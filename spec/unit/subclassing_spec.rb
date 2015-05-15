require 'spec_helper'

describe 'subclassing' do

  it 'should have the parent states' do
    SuperClass.aasm.states.each do |state|
      expect(SubClassWithMoreStates.aasm.states).to include(state)
    end
    expect(SubClass.aasm.states).to eq(SuperClass.aasm.states)
  end

  it 'should not add the child states to the parent machine' do
    expect(SuperClass.aasm.states).not_to include(:foo)
  end

  it "should have the same events as its parent" do
    expect(SubClass.aasm.events).to eq(SuperClass.aasm.events)
  end

  it 'should know how to respond to question methods' do
    expect(SubClass.new.may_foo?).to be_truthy
  end

  it 'should not break if I call methods from super class' do
    son = SubClass.new
    son.update_state
    expect(son.aasm.current_state).to eq(:ended)
  end

end

