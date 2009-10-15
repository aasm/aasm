require 'test_helper'

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

class AuthMachineTest < Test::Unit::TestCase
  context 'authentication state machine' do
    context 'on initialization' do
      setup do
        @auth = AuthMachine.new
      end

      should 'be in the pending state' do
        assert_equal :pending, @auth.aasm_current_state
      end

      should 'have an activation code' do
        assert @auth.has_activation_code?
        assert_not_nil @auth.activation_code
      end
    end

    context 'when being unsuspended' do
      should 'be active if previously activated' do
        @auth = AuthMachine.new
        @auth.activate!
        @auth.suspend!
        @auth.unsuspend!

        assert_equal :active, @auth.aasm_current_state
      end

      should 'be pending if not previously activated, but an activation code is present' do
        @auth = AuthMachine.new
        @auth.suspend!
        @auth.unsuspend!

        assert_equal :pending, @auth.aasm_current_state
      end

      should 'be passive if not previously activated and there is no activation code' do
        @auth = AuthMachine.new
        @auth.activation_code = nil
        @auth.suspend!
        @auth.unsuspend!

        assert_equal :passive, @auth.aasm_current_state
      end
    end

  end
end
