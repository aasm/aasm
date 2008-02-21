require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'aasm')

class Conversation
  include AASM

  initial_state :needs_attention

  state :needs_attention
  state :read
  state :closed
  state :awaiting_response
  state :junk

  event :new_message do
  end

  event :view do
    transitions :to => :read, :from => [:needs_attention]
  end

  event :reply do
  end

  event :close do
    transitions :to => :closed, :from => [:read, :awaiting_response]
  end

  event :junk do
    transitions :to => :junk, :from => [:read]
  end

  event :unjunk do
  end

  def initialize(persister)
    @persister = persister
  end


  private
  def aasm_read_state
    @persister.read_state
  end

  def aasm_write_state(state)
    @persister.write_state(state)
  end
end
