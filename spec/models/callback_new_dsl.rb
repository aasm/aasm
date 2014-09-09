class CallbackNewDsl
  include AASM

  def initialize(options={})
    @fail_event_guard = options[:fail_event_guard]
    @fail_transition_guard = options[:fail_transition_guard]
  end

  aasm do
    state :open, :initial => true,
      :before_enter => :before_enter_open,
      :enter        => :enter_open,
      :after_enter  => :after_enter_open,
      :before_exit  => :before_exit_open,
      :exit         => :exit_open,
      :after_exit   => :after_exit_open

    state :closed,
      :before_enter => :before_enter_closed,
      :enter        => :enter_closed,
      :after_enter  => :after_enter_closed,
      :before_exit  => :before_exit_closed,
      :exit         => :exit_closed,
      :after_exit   => :after_exit_closed

    event :close, :before => :before, :after => :after, :guard => :event_guard do
      transitions :to => :closed, :from => [:open], :guard => :transition_guard, :on_transition => :transitioning
    end

    event :open, :before => :before, :after => :after do
      transitions :to => :open, :from => :closed
    end
  end

  def log(text)
    # puts text
  end

  def before_enter_open; log('before_enter_open'); end
  def enter_open; log('enter_open'); end
  def before_exit_open; log('before_exit_open'); end
  def after_enter_open; log('after_enter_open'); end
  def exit_open; log('exit_open'); end
  def after_exit_open; log('after_exit_open'); end

  def before_enter_closed; log('before_enter_closed'); end
  def enter_closed; log('enter_closed'); end
  def before_exit_closed; log('before_exit_closed'); end
  def exit_closed; log('exit_closed'); end
  def after_enter_closed; log('after_enter_closed'); end
  def after_exit_closed; log('after_exit_closed'); end

  def event_guard; log('event_guard'); !@fail_event_guard; end
  def transition_guard; log('transition_guard'); !@fail_transition_guard; end
  def transitioning; log('transitioning'); end

  def before; log('before'); end
  def after; log('after'); end
end

class CallbackNewDslArgs
  include AASM

  aasm do
    state :open, :initial => true,
      :before_enter => :before_enter_open,
      :after_enter  => :after_enter_open,
      :before_exit  => :before_exit_open,
      :after_exit   => :after_exit_open

    state :closed,
      :before_enter => :before_enter_closed,
      :after_enter  => :after_enter_closed,
      :before_exit  => :before_exit_closed,
      :after_exit   => :after_exit_closed

    event :close, :before => :before, :after => :after do
      transitions :to => :closed, :from => [:open], :on_transition => :transition_proc
    end

    event :open, :before => :before, :after => :after do
      transitions :to => :open, :from => :closed
    end
  end

  def log(text)
    # puts text
  end

  def before_enter_open; log('before_enter_open'); end
  def before_exit_open; log('before_exit_open'); end
  def after_enter_open; log('after_enter_open'); end
  def after_exit_open; log('after_exit_open'); end

  def before_enter_closed; log('before_enter_closed'); end
  def before_exit_closed; log('before_enter_closed'); end
  def after_enter_closed; log('after_enter_closed'); end
  def after_exit_closed; log('after_exit_closed'); end

  def before(*args); log('before'); end
  def transition_proc(arg1, arg2); log('transition_proc'); end
  def after(*args); log('after'); end
end

class CallbackWithStateArg

  include AASM

  aasm do
    state :open, :inital => true
    state :closed
    state :out_to_lunch

    event :close, :before => :before_method, :after => :after_method do
      transitions :to => :closed, :from => [:open], :on_transition => :transition_method
      transitions :to => :out_to_lunch, :from => [:open], :on_transition => :transition_method2
    end
  end

  def before_method(arg); end

  def after_method(arg); end

  def transition_method(arg); end

  def transition_method2(arg); end

end
