require 'spec_helper'

describe 'state machine' do
  let(:simple) { SimpleExample.new }

  it 'starts with an initial state' do
    expect(simple.aasm.current_state).to eq(:initialised)
    expect(simple).to respond_to(:initialised?)
    expect(simple).to be_initialised
  end

  it 'allows transitions to other states' do
    expect(simple).to respond_to(:fill_out)
    expect(simple).to respond_to(:fill_out!)
    simple.fill_out!
    expect(simple).to respond_to(:filled_out?)
    expect(simple).to be_filled_out

    expect(simple).to respond_to(:authorise)
    expect(simple).to respond_to(:authorise!)
    simple.authorise
    expect(simple).to respond_to(:authorised?)
    expect(simple).to be_authorised
  end

  it 'denies transitions to other states' do
    expect {simple.authorise}.to raise_error(AASM::InvalidTransition)
    expect {simple.authorise!}.to raise_error(AASM::InvalidTransition)
    simple.fill_out
    expect {simple.fill_out}.to raise_error(AASM::InvalidTransition)
    expect {simple.fill_out!}.to raise_error(AASM::InvalidTransition)
    simple.authorise
    expect {simple.fill_out}.to raise_error(AASM::InvalidTransition)
    expect {simple.fill_out!}.to raise_error(AASM::InvalidTransition)
  end

  it 'defines constants for each state name' do
    expect(SimpleExample::STATE_INITIALISED).to eq(:initialised)
    expect(SimpleExample::STATE_FILLED_OUT).to eq(:filled_out)
    expect(SimpleExample::STATE_AUTHORISED).to eq(:authorised)
  end
end
