module Callbacks
  class WithArgs
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
        transitions :to => :closed, :from => [:open], :after => :transition_proc
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
end
