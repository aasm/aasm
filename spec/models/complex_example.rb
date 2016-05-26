class ComplexExample
  include AASM

  attr_accessor :activation_code, :activated_at, :deleted_at

  aasm do
    state :passive
    state :pending, :initial => true, :before_enter => :make_activation_code
    state :active,  :before_enter => :do_activate
    state :suspended
    state :deleted, :before_enter => :do_delete#, :exit => :do_undelete
    state :waiting

    event :register do
      transitions :from => :passive, :to => :pending do
        guard do
          can_register?
        end
      end
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
      transitions :from => :suspended, :to => :active,  :guard => Proc.new { has_activated? }
      transitions :from => :suspended, :to => :pending, :guard => :has_activation_code?
      transitions :from => :suspended, :to => :passive
    end

    event :wait do
      transitions :from => :suspended, :to => :waiting, :guard => :if_polite?
    end
  end

  def initialize
    # the AR backend uses a before_validate_on_create :aasm_ensure_initial_state
    # lets do something similar here for testing purposes.
    aasm.enter_initial_state
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

class ComplexExampleMultiple
  include AASM

  attr_accessor :activation_code, :activated_at, :deleted_at

  aasm(:left) do
    state :passive
    state :pending, :initial => true, :before_enter => :make_activation_code
    state :active,  :before_enter => :do_activate
    state :suspended
    state :deleted, :before_enter => :do_delete#, :exit => :do_undelete
    state :waiting

    event :left_register do
      transitions :from => :passive, :to => :pending do
        guard do
          can_register?
        end
      end
    end

    event :left_activate do
      transitions :from => :pending, :to => :active
    end

    event :left_suspend do
      transitions :from => [:passive, :pending, :active], :to => :suspended
    end

    event :left_delete do
      transitions :from => [:passive, :pending, :active, :suspended], :to => :deleted
    end

    # a dummy event that can never happen
    event :left_unpassify do
      transitions :from => :passive, :to => :active, :guard => Proc.new {|u| false }
    end

    event :left_unsuspend do
      transitions :from => :suspended, :to => :active,  :guard => Proc.new { has_activated? }
      transitions :from => :suspended, :to => :pending, :guard => :has_activation_code?
      transitions :from => :suspended, :to => :passive
    end

    event :left_wait do
      transitions :from => :suspended, :to => :waiting, :guard => :if_polite?
    end
  end

  aasm(:right) do
    state :passive
    state :pending, :initial => true, :before_enter => :make_activation_code
    state :active,  :before_enter => :do_activate
    state :suspended
    state :deleted, :before_enter => :do_delete#, :exit => :do_undelete
    state :waiting

    event :right_register do
      transitions :from => :passive, :to => :pending do
        guard do
          can_register?
        end
      end
    end

    event :right_activate do
      transitions :from => :pending, :to => :active
    end

    event :right_suspend do
      transitions :from => [:passive, :pending, :active], :to => :suspended
    end

    event :right_delete do
      transitions :from => [:passive, :pending, :active, :suspended], :to => :deleted
    end

    # a dummy event that can never happen
    event :right_unpassify do
      transitions :from => :passive, :to => :active, :guard => Proc.new {|u| false }
    end

    event :right_unsuspend do
      transitions :from => :suspended, :to => :active,  :guard => Proc.new { has_activated? }
      transitions :from => :suspended, :to => :pending, :guard => :has_activation_code?
      transitions :from => :suspended, :to => :passive
    end

    event :right_wait do
      transitions :from => :suspended, :to => :waiting, :guard => :if_polite?
    end
  end # right

  def initialize
    # the AR backend uses a before_validate_on_create :aasm_ensure_initial_state
    # lets do something similar here for testing purposes.
    aasm(:left).enter_initial_state
    aasm(:right).enter_initial_state
  end

  def make_activation_code
    @activation_code = @activation_code ? @activation_code + '2' : '1'
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
