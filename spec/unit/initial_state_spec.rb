require 'spec_helper'

describe 'initial states' do
  it 'should use the first state defined if no initial state is given' do
    expect(NoInitialState.new.aasm.current_state).to eq(:read)
  end

  it 'should determine initial state from the Proc results' do
    expect(InitialStateProc.new(InitialStateProc::RICH - 1).aasm.current_state).to eq(:selling_bad_mortgages)
    expect(InitialStateProc.new(InitialStateProc::RICH + 1).aasm.current_state).to eq(:retired)
  end
end
