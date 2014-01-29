require 'spec_helper'

class Banker
  include AASM
  aasm do
    state :retired
    state :selling_bad_mortgages
    initial_state Proc.new { |banker| banker.rich? ? :retired : :selling_bad_mortgages }
  end
  RICH = 1_000_000
  attr_accessor :balance
  def initialize(balance = 0); self.balance = balance; end
  def rich?; self.balance >= RICH; end
end

describe 'initial states' do
  let(:bar) {Bar.new}

  it 'should use the first state defined if no initial state is given' do
    expect(bar.aasm.current_state).to eq(:read)
  end

  it 'should determine initial state from the Proc results' do
    expect(Banker.new(Banker::RICH - 1).aasm.current_state).to eq(:selling_bad_mortgages)
    expect(Banker.new(Banker::RICH + 1).aasm.current_state).to eq(:retired)
  end
end
