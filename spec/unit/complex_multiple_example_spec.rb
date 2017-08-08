require 'spec_helper'

describe 'on initialization' do
  let(:auth) {ComplexExampleMultiple.new}

  it 'should be in the initial state' do
    expect(auth.aasm(:left).current_state).to eq(:pending)
    expect(auth.aasm(:right).current_state).to eq(:pending)
  end

  it 'should have an activation code' do
    expect(auth.has_activation_code?).to be_truthy
    expect(auth.activation_code).to eq '12'
  end
end

describe 'when being unsuspended' do
  let(:auth) {ComplexExampleMultiple.new}

  it 'should be able to unsuspend' do
    auth.left_activate!
    auth.left_suspend!
    expect(auth.may_left_unsuspend?).to be true

    auth.right_activate!
    auth.right_suspend!
    expect(auth.may_right_unsuspend?).to be true
  end

  it 'should not be able to unsuspend into active' do
    auth.left_suspend!
    expect(auth.may_left_unsuspend?(:active)).not_to be true

    auth.right_activate!
    auth.right_suspend!
    expect(auth.may_right_unsuspend?(:active)).to be true
  end

  it 'should be able to wait into waiting if polite' do
    auth.left_suspend!
    expect(auth.may_left_wait?(:waiting, :please)).to be true
    auth.left_wait!(:please)

    auth.right_suspend!
    expect(auth.may_right_wait?(:waiting)).to be false
    auth.right_wait!(:please)
  end

  it 'should not be able to be unsuspended into active if not polite' do
    auth.left_suspend!
    expect(auth.may_left_wait?(:waiting)).not_to be true
    expect(auth.may_left_wait?(:waiting, :rude)).not_to be true
    expect {auth.left_wait!(:rude)}.to raise_error(AASM::InvalidTransition)
    expect {auth.left_wait!}.to raise_error(AASM::InvalidTransition)
  end

  it 'should not be able to be unpassified' do
    auth.left_activate!
    auth.left_suspend!
    auth.left_unsuspend!

    expect(auth.may_left_unpassify?).not_to be true
    expect {auth.left_unpassify!}.to raise_error(AASM::InvalidTransition)
  end

  it 'should be active if previously activated' do
    auth.left_activate!
    auth.left_suspend!
    auth.left_unsuspend!

    expect(auth.aasm(:left).current_state).to eq(:active)
  end

  it 'should be pending if not previously activated, but an activation code is present' do
    auth.left_suspend!
    auth.left_unsuspend!

    expect(auth.aasm(:left).current_state).to eq(:pending)
  end

  it 'should be passive if not previously activated and there is no activation code' do
    auth.activation_code = nil
    auth.left_suspend!
    auth.left_unsuspend!

    expect(auth.aasm(:left).current_state).to eq(:passive)
  end

  it "should be able to fire known events" do
    expect(auth.aasm(:left).may_fire_event?(:left_activate)).to be true
    expect(auth.aasm(:right).may_fire_event?(:right_activate)).to be true
  end

  it 'should not be able to fire unknown events' do
    expect(auth.aasm(:left).may_fire_event?(:unknown)).to be false
    expect(auth.aasm(:right).may_fire_event?(:unknown)).to be false
  end

  it 'should be able to fire event by name' do
    expect(auth.aasm(:left).fire(:left_activate)).to be true
    expect(auth.aasm(:left).current_state).to eq(:active)

    expect(auth.aasm(:right).fire(:right_activate)).to be true
    expect(auth.aasm(:right).current_state).to eq(:active)
  end

  it 'should be able to fire! event by name' do
    expect(auth.aasm(:left).fire!(:left_activate)).to be true
    expect(auth.aasm(:left).current_state).to eq(:active)

    expect(auth.aasm(:right).fire!(:right_activate)).to be true
    expect(auth.aasm(:right).current_state).to eq(:active)
  end

end
