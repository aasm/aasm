require 'spec_helper'

class SimpleStateMachine
  include AASM

  aasm do
    state :init, :initial => true
    state :failed

    event :failed do
      transitions :from => :init, :to => :failed
    end
  end
end

describe "event naming" do
  let(:state_machine) { SimpleStateMachine.new }

  it "allows an event of failed without blowing the stack" do
    state_machine.failed

    expect { state_machine.failed }.to raise_error(AASM::InvalidTransition)
  end
end
