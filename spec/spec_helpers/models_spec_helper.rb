Dir[File.dirname(__FILE__) + "/../models/*.rb"].sort.each { |f| require File.expand_path(f) }

class Foo
  include AASM
  aasm do
    state :open, :initial => true, :exit => :exit
    state :closed, :enter => :enter

    event :close, :success => :success_callback do
      transitions :to => :closed, :from => [:open]
    end

    event :null do
      transitions :to => :closed, :from => [:open], :guard => :always_false
    end
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
  aasm do
    state :foo
  end
end

class Bar
  include AASM

  aasm do
    state :read
    state :ended

    event :foo do
      transitions :to => :ended, :from => [:read]
    end
  end
end

class Baz < Bar
end

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

class ThisNameBetterNotBeInUse
  include AASM

  aasm do
    state :initial
    state :symbol
    state :string
    state :array
    state :proc
  end
end
