require 'spec_helper'

describe "event naming" do
  let(:state_machine) { StateMachineWithFailedEvent.new }

  it "allows an event of failed without blowing the stack aka stack level too deep" do
    state_machine.failed
    expect { state_machine.failed }.to raise_error(AASM::InvalidTransition)
  end

  it "allows send as event name" do
    expect(state_machine.aasm.current_state).to eq :init
    state_machine.send
    expect(state_machine.aasm.current_state).to eq :sent
  end
end
