require 'spec_helper'

describe 'initial states' do
  it 'should use the first state defined if no initial state is given' do
    expect(NoInitialStateMultiple.new.aasm(:left).current_state).to eq(:read)
  end

  it 'should determine initial state from the Proc results' do
    balance = InitialStateProcMultiple::RICH - 1
    expect(InitialStateProcMultiple.new(balance).aasm(:left).current_state).to eq(:selling_bad_mortgages)

    balance = InitialStateProcMultiple::RICH + 1
    expect(InitialStateProcMultiple.new(balance).aasm(:left).current_state).to eq(:retired)
  end
end
