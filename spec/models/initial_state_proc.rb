class InitialStateProc
  RICH = 1_000_000

  attr_accessor :balance

  include AASM
  aasm do
    state :retired
    state :selling_bad_mortgages
    initial_state Proc.new { |banker| banker.rich? ? :retired : :selling_bad_mortgages }
  end

  def initialize(balance = 0); self.balance = balance; end
  def rich?; self.balance >= RICH; end
end

class InitialStateProcMultiple
  RICH = 1_000_000

  attr_accessor :balance

  include AASM
  aasm(:left) do
    state :retired
    state :selling_bad_mortgages
    initial_state Proc.new { |banker| banker.rich? ? :retired : :selling_bad_mortgages }
  end

  def initialize(balance = 0); self.balance = balance; end
  def rich?; self.balance >= RICH; end
end
