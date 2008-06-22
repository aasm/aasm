describe Conversation, 'description' do
  it '.aasm_states should contain all of the states' do
    Conversation.aasm_states.should == [:needs_attention, :read, :closed, :awaiting_response, :junk]
  end
end
