require 'spec_helper'

class Payment
  include AASM
  aasm do
    state :initialised, :initial => true
    state :filled_out
    state :authorised

    event :fill_out do
      transitions :from => :initialised, :to => :filled_out
    end
    event :authorise do
      transitions :from => :filled_out, :to => :authorised
    end
  end
end

describe 'state machine' do
  let(:payment) {Payment.new}

  it 'starts with an initial state' do
    expect(payment.aasm.current_state).to eq(:initialised)
    expect(payment).to respond_to(:initialised?)
    expect(payment).to be_initialised
  end

  it 'allows transitions to other states' do
    expect(payment).to respond_to(:fill_out)
    expect(payment).to respond_to(:fill_out!)
    payment.fill_out!
    expect(payment).to respond_to(:filled_out?)
    expect(payment).to be_filled_out

    expect(payment).to respond_to(:authorise)
    expect(payment).to respond_to(:authorise!)
    payment.authorise
    expect(payment).to respond_to(:authorised?)
    expect(payment).to be_authorised
  end

  it 'denies transitions to other states' do
    expect {payment.authorise}.to raise_error(AASM::InvalidTransition)
    expect {payment.authorise!}.to raise_error(AASM::InvalidTransition)
    payment.fill_out
    expect {payment.fill_out}.to raise_error(AASM::InvalidTransition)
    expect {payment.fill_out!}.to raise_error(AASM::InvalidTransition)
    payment.authorise
    expect {payment.fill_out}.to raise_error(AASM::InvalidTransition)
    expect {payment.fill_out!}.to raise_error(AASM::InvalidTransition)
  end

  it 'defines constants for each state name' do
    expect(Payment::STATE_INITIALISED).to eq(:initialised)
    expect(Payment::STATE_FILLED_OUT).to eq(:filled_out)
    expect(Payment::STATE_AUTHORISED).to eq(:authorised)
  end
end
