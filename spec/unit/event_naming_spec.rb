require 'spec_helper'

describe "event naming" do
  let(:state_machine) { SimpleStateMachine.new }

  it "allows an event of failed without blowing the stack" do
    state_machine.failed

    expect { state_machine.failed }.to raise_error(AASM::InvalidTransition)
  end
end
