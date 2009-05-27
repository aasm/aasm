require File.join(File.dirname(__FILE__), "..", "spec_helper")
require File.join(File.dirname(__FILE__), 'conversation')

describe Conversation, 'description' do
  it '.aasm_states should contain all of the states' do
    Conversation.aasm_states.should == [:needs_attention, :read, :closed, :awaiting_response, :junk]
  end
end
