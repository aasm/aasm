require 'spec_helper'

class Banker
  include AASM
  aasm do
    state :retired
    state :selling_bad_mortgages
  end
  aasm_initial_state  Proc.new { |banker| banker.rich? ? :retired : :selling_bad_mortgages }
  RICH = 1_000_000
  attr_accessor :balance
  def initialize(balance = 0); self.balance = balance; end
  def rich?; self.balance >= RICH; end
end

describe 'initial states' do
  let(:bar) {Bar.new}

  it 'should use the first state defined if no initial state is given' do
    bar.aasm_current_state.should == :read
    # bar.aasm.current_state.should == :read # not yet supported
  end

  it 'should determine initial state from the Proc results' do
    Banker.new(Banker::RICH - 1).aasm_current_state.should == :selling_bad_mortgages
    Banker.new(Banker::RICH + 1).aasm_current_state.should == :retired
  end
end
