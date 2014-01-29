require 'spec_helper'

describe 'subclassing' do
  let(:son) {Son.new}

  it 'should have the parent states' do
    Foo.aasm.states.each do |state|
      expect(FooTwo.aasm.states).to include(state)
    end
    expect(Baz.aasm.states).to eq(Bar.aasm.states)
  end

  it 'should not add the child states to the parent machine' do
    expect(Foo.aasm.states).not_to include(:foo)
  end

  it "should have the same events as its parent" do
    expect(Baz.aasm.events).to eq(Bar.aasm.events)
  end

  it 'should know how to respond to `may_add_details?`' do
    expect(son.may_add_details?).to be_true
  end

  it 'should not break if I call Son#update_state' do
    son.update_state
    expect(son.aasm.current_state).to eq(:pending_details_confirmation)
  end

end

