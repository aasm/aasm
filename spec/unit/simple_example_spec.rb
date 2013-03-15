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
    payment.aasm_current_state.should == :initialised
    # payment.aasm.current_state.should == :initialised # not yet supported
    payment.should respond_to(:initialised?)
    payment.should be_initialised
  end

  it 'allows transitions to other states' do
    payment.should respond_to(:fill_out)
    payment.should respond_to(:fill_out!)
    payment.fill_out!
    payment.should respond_to(:filled_out?)
    payment.should be_filled_out

    payment.should respond_to(:authorise)
    payment.should respond_to(:authorise!)
    payment.authorise
    payment.should respond_to(:authorised?)
    payment.should be_authorised
  end

  it 'denies transitions to other states' do
    lambda {payment.authorise}.should raise_error(AASM::InvalidTransition)
    lambda {payment.authorise!}.should raise_error(AASM::InvalidTransition)
    payment.fill_out
    lambda {payment.fill_out}.should raise_error(AASM::InvalidTransition)
    lambda {payment.fill_out!}.should raise_error(AASM::InvalidTransition)
    payment.authorise
    lambda {payment.fill_out}.should raise_error(AASM::InvalidTransition)
    lambda {payment.fill_out!}.should raise_error(AASM::InvalidTransition)
  end

  it 'defines constants for each state name' do
    Payment::STATE_INITIALISED.should eq(:initialised)
    Payment::STATE_FILLED_OUT.should eq(:filled_out)
    Payment::STATE_AUTHORISED.should eq(:authorised)
  end
end
