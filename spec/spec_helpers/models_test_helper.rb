class Foo
  include AASM
  aasm_initial_state :open
  aasm_state :open, :exit => :exit
  aasm_state :closed, :enter => :enter

  aasm_event :close, :success => :success_callback do
    transitions :to => :closed, :from => [:open]
  end

  aasm_event :null do
    transitions :to => :closed, :from => [:open], :guard => :always_false
  end

  def always_false
    false
  end

  def success_callback
  end

  def enter
  end
  def exit
  end
end

class FooTwo < Foo
  include AASM
  aasm_state :foo
end

class Bar
  include AASM

  aasm_state :read
  aasm_state :ended

  aasm_event :foo do
    transitions :to => :ended, :from => [:read]
  end
end

class Baz < Bar
end

class Banker
  include AASM
  aasm_initial_state  Proc.new { |banker| banker.rich? ? :retired : :selling_bad_mortgages }
  aasm_state          :retired
  aasm_state          :selling_bad_mortgages
  RICH = 1_000_000
  attr_accessor :balance
  def initialize(balance = 0); self.balance = balance; end
  def rich?; self.balance >= RICH; end
end

class Argument
  include AASM
  aasm_initial_state :invalid
  aasm_state :invalid
  aasm_state :valid

  aasm_event :valid do
    transitions :to => :valid, :from => [:invalid]
  end
end
