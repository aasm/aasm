require 'spec_helper'

describe 'inspecting AASM' do
  it 'should support listing all states in the order they have been defined' do
    Conversation.aasm_states.should == [:needs_attention, :read, :closed, :awaiting_response, :junk]
  end
end
