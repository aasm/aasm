require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe 'aasm_states' do
  it 'should contain all of the states' do
    Conversation.aasm_states.should == [:needs_attention, :read, :closed, :awaiting_response, :junk]
  end
end
