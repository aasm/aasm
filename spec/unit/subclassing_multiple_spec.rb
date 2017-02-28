require 'spec_helper'

describe 'subclassing with multiple state machines' do

  it 'should have the parent states' do
    SuperClassMultiple.aasm(:left).states.each do |state|
      expect(SubClassWithMoreStatesMultiple.aasm(:left).states).to include(state)
    end
    expect(SubClassMultiple.aasm(:left).states).to eq(SuperClassMultiple.aasm(:left).states)

    SuperClassMultiple.aasm(:right).states.each do |state|
      expect(SubClassWithMoreStatesMultiple.aasm(:right).states).to include(state)
    end
    expect(SubClassMultiple.aasm(:right).states).to eq(SuperClassMultiple.aasm(:right).states)
  end

  it 'should not add the child states to the parent machine' do
    expect(SuperClassMultiple.aasm(:left).states).not_to include(:foo)
    expect(SuperClassMultiple.aasm(:right).states).not_to include(:archived)
  end

  it 'should have the same events as its parent' do
    expect(SubClassMultiple.aasm(:left).events).to eq(SuperClassMultiple.aasm(:left).events)
    expect(SubClassMultiple.aasm(:right).events).to eq(SuperClassMultiple.aasm(:right).events)
  end

  it 'should know how to respond to question methods' do
    expect(SubClassMultiple.new.may_foo?).to be_truthy
    expect(SubClassMultiple.new.may_close?).to be_truthy
  end

  it 'should not break if I call methods from super class' do
    son = SubClassMultiple.new
    son.update_state
    expect(son.aasm(:left).current_state).to eq(:ended)
  end

  it 'should allow the child to modify its left state machine ..' do
    son = SubClassMultiple.new
    expect(son.left_called_after).to eq(nil)
    expect(son.right_called_after).to eq(nil)
    son.foo
    expect(son.left_called_after).to eq(true)
    expect(son.right_called_after).to eq(nil)
  end

  it 'should allow the child to modify its right state machine' do
    son = SubClassMultiple.new
    expect(son.right_called_after).to eq(nil)
    expect(son.left_called_after).to eq(nil)
    son.close
    expect(son.right_called_after).to eq(true)
    expect(son.left_called_after).to eq(nil)
  end

end

