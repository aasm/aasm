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

  it 'should have the same events as its parent' do
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

  it 'should allow the child to modify its state machine' do
    son = SubClass.new
    expect(son.called_after).to eq(nil)
    son.foo
    expect(son.called_after).to eq(true)
    global_callbacks = SubClass.aasm.state_machine.global_callbacks
    expect(global_callbacks).to_not be_empty
    expect(global_callbacks[:after_all_transitions]).to eq :after_all_event
  end

  it 'should not modify the parent state machine' do
    super_class_event = SuperClass.aasm.events.select { |event| event.name == :foo }.first
    expect(super_class_event.options).to be_empty
    expect(SuperClass.aasm.state_machine.global_callbacks).to be_empty
  end

end
