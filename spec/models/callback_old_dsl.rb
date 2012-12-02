class CallbackOldDsl
  include AASM

  aasm_initial_state :open
  aasm_state :open,
    :before_enter => :before_enter_open,
    :after_enter  => :after_enter_open,
    :before_exit  => :before_exit_open,
    :exit         => :exit_open,
    :after_exit   => :after_exit_open
  aasm_state :closed,
    :before_enter => :before_enter_closed,
    :enter        => :enter_closed,
    :after_enter  => :after_enter_closed,
    :before_exit  => :before_exit_closed,
    :after_exit   => :after_exit_closed

  aasm_event :close, :before => :before, :after => :after do
    transitions :to => :closed, :from => [:open]
  end

  aasm_event :open, :before => :before, :after => :after do
    transitions :to => :open, :from => :closed
  end

  def before_enter_open; end
  def before_exit_open; end
  def after_enter_open; end
  def after_exit_open; end

  def before_enter_closed; end
  def before_exit_closed; end
  def after_enter_closed; end
  def after_exit_closed; end

  def before; end
  def after; end

  def enter_closed; end
  def exit_open; end
end
