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

class Argument
  include AASM
  aasm do
    state :invalid, :initial => true
    state :valid

    event :valid do
      transitions :to => :valid, :from => [:invalid]
    end
  end
end

class AuthMachine
  include AASM

  attr_accessor :activation_code, :activated_at, :deleted_at

  aasm do
    state :passive
    state :pending, :initial => true, :enter => :make_activation_code
    state :active,  :enter => :do_activate
    state :suspended
    state :deleted, :enter => :do_delete, :exit => :do_undelete

    event :register do
      transitions :from => :passive, :to => :pending, :guard => Proc.new {|u| u.can_register? }
    end

    event :activate do
      transitions :from => :pending, :to => :active
    end

    event :suspend do
      transitions :from => [:passive, :pending, :active], :to => :suspended
    end

    event :delete do
      transitions :from => [:passive, :pending, :active, :suspended], :to => :deleted
    end

    # a dummy event that can never happen
    event :unpassify do
      transitions :from => :passive, :to => :active, :guard => Proc.new {|u| false }
    end
  
    event :unsuspend do
      transitions :from => :suspended, :to => :active,  :guard => Proc.new {|u| u.has_activated? }
      transitions :from => :suspended, :to => :active,  :guard => :if_polite?
      transitions :from => :suspended, :to => :pending, :guard => Proc.new {|u| u.has_activation_code? }
      transitions :from => :suspended, :to => :passive
    end
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

  def if_polite?(phrase = nil)
    phrase == :please
  end
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

class ChetanPatil
  include AASM
  aasm do
    state :sleeping, :initial => true
    state :showering
    state :working
    state :dating
    state :prettying_up

    event :wakeup do
      transitions :from => :sleeping, :to => [:showering, :working]
    end

    event :dress do
      transitions :from => :sleeping, :to => :working, :on_transition => :wear_clothes
      transitions :from => :showering, :to => [:working, :dating], :on_transition => Proc.new { |obj, *args| obj.wear_clothes(*args) }
      transitions :from => :showering, :to => :prettying_up, :on_transition => [:condition_hair, :fix_hair]
    end
  end

  def wear_clothes(shirt_color, trouser_type)
  end

  def condition_hair
  end

  def fix_hair
  end
end
