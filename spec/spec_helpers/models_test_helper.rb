Dir[File.dirname(__FILE__) + "/models/**/*.rb"].each { |f| require File.expand_path(f) }

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

class AuthMachine
  include AASM

  attr_accessor :activation_code, :activated_at, :deleted_at

  aasm_initial_state :pending

  aasm_state :passive
  aasm_state :pending, :enter => :make_activation_code
  aasm_state :active,  :enter => :do_activate
  aasm_state :suspended
  aasm_state :deleted, :enter => :do_delete, :exit => :do_undelete

  aasm_event :register do
    transitions :from => :passive, :to => :pending, :guard => Proc.new {|u| u.can_register? }
  end

  aasm_event :activate do
    transitions :from => :pending, :to => :active
  end

  aasm_event :suspend do
    transitions :from => [:passive, :pending, :active], :to => :suspended
  end

  aasm_event :delete do
    transitions :from => [:passive, :pending, :active, :suspended], :to => :deleted
  end

  # a dummy event that can never happen
  aasm_event :unpassify do
    transitions :from => :passive, :to => :active, :guard => Proc.new {|u| false }
  end
  
  aasm_event :unsuspend do
    transitions :from => :suspended, :to => :active,  :guard => Proc.new {|u| u.has_activated? }
    transitions :from => :suspended, :to => :pending, :guard => Proc.new {|u| u.has_activation_code? }
    transitions :from => :suspended, :to => :passive
  end

  def initialize
    # the AR backend uses a before_validate_on_create :aasm_ensure_initial_state
    # lets do something similar here for testing purposes.
    aasm_enter_initial_state
  end

  def make_activation_code
    @activation_code = 'moo'
  end

  def do_activate
    @activated_at = Time.now
    @activation_code = nil
  end

  def do_delete
    @deleted_at = Time.now
  end

  def do_undelete
    @deleted_at = false
  end

  def can_register?
    true
  end

  def has_activated?
    !!@activated_at
  end

  def has_activation_code?
    !!@activation_code
  end
end

class ThisNameBetterNotBeInUse
  include AASM

  aasm_state :initial
  aasm_state :symbol
  aasm_state :string
  aasm_state :array
  aasm_state :proc
end

class ChetanPatil
  include AASM
  aasm_initial_state :sleeping
  aasm_state :sleeping
  aasm_state :showering
  aasm_state :working
  aasm_state :dating
  aasm_state :prettying_up

  aasm_event :wakeup do
    transitions :from => :sleeping, :to => [:showering, :working]
  end

  aasm_event :dress do
    transitions :from => :sleeping, :to => :working, :on_transition => :wear_clothes
    transitions :from => :showering, :to => [:working, :dating], :on_transition => Proc.new { |obj, *args| obj.wear_clothes(*args) }
    transitions :from => :showering, :to => :prettying_up, :on_transition => [:condition_hair, :fix_hair]
  end

  def wear_clothes(shirt_color, trouser_type)
  end

  def condition_hair
  end

  def fix_hair
  end
end
