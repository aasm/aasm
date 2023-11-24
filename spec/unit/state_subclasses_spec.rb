require 'spec_helper'

describe 'customized event classes' do
  let(:example) { SimpleExampleWithCustomAasmBase.new }

  it 'should create custom state classes' do
    state = example.aasm(:default).states.first

    expect(state).to be_a(CustomState)
    expect(state.custom_state_method(7)).to eq(49)
  end
end
