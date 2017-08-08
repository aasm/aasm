require 'spec_helper'

describe 'on initialization' do
  let(:auth) {ComplexExample.new}

  it 'should be in the pending state' do
    expect(auth.aasm.current_state).to eq(:pending)
  end

  it 'should have an activation code' do
    expect(auth.has_activation_code?).to be_truthy
    expect(auth.activation_code).not_to be_nil
  end
end

describe 'when being unsuspended' do
  let(:auth) {ComplexExample.new}

  it 'should be able to be unsuspended' do
    auth.activate!
    auth.suspend!
    expect(auth.may_unsuspend?).to be true
  end

  it 'should not be able to be unsuspended into active' do
    auth.suspend!
    expect(auth.may_unsuspend?(:active)).not_to be true
  end

  it 'should be able to be unsuspended into active if polite' do
    auth.suspend!
    expect(auth.may_wait?(:waiting, :please)).to be true
    auth.wait!(:please)
  end

  it 'should not be able to be unsuspended into active if not polite' do
    auth.suspend!
    expect(auth.may_wait?(:waiting)).not_to be true
    expect(auth.may_wait?(:waiting, :rude)).not_to be true
    expect {auth.wait!(:rude)}.to raise_error(AASM::InvalidTransition)
    expect {auth.wait!}.to raise_error(AASM::InvalidTransition)
  end

  it 'should not be able to be unpassified' do
    auth.activate!
    auth.suspend!
    auth.unsuspend!

    expect(auth.may_unpassify?).not_to be true
    expect {auth.unpassify!}.to raise_error(AASM::InvalidTransition)
  end

  it 'should be active if previously activated' do
    auth.activate!
    auth.suspend!
    auth.unsuspend!

    expect(auth.aasm.current_state).to eq(:active)
  end

  it 'should be pending if not previously activated, but an activation code is present' do
    auth.suspend!
    auth.unsuspend!

    expect(auth.aasm.current_state).to eq(:pending)
  end

  it 'should be passive if not previously activated and there is no activation code' do
    auth.activation_code = nil
    auth.suspend!
    auth.unsuspend!

    expect(auth.aasm.current_state).to eq(:passive)
  end

  it "should be able to fire known events" do
    expect(auth.aasm.may_fire_event?(:activate)).to be true
  end

  it "should be able to fire event by name" do
    expect(auth.aasm.fire(:activate)).to be true
    expect(auth.aasm.current_state).to eq(:active)
  end

  it "should be able to fire! event by name" do
    expect(auth.aasm.fire!(:activate)).to be true
    expect(auth.aasm.current_state).to eq(:active)
  end

  it "should not be able to fire unknown events" do
    expect(auth.aasm.may_fire_event?(:unknown)).to be false
  end

end
