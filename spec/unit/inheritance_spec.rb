require 'spec_helper'

describe 'inheritance behavior' do
  let(:son) {Son.new}

  it 'should be in the pending state' do
    son.aasm_current_state.should == :missing_details
  end

  it 'should know how to respond to `may_add_details?`' do
    son.may_add_details?.should be_true
  end

  it 'should not break if I call Son#update_state' do
    son.update_state
    son.aasm_current_state.should == :pending_details_confirmation
  end
end