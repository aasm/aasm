module Callbacks
  class GuardWithinBlock
    include AASM

    def initialize(options={})
      @fail_event_guard = options[:fail_event_guard]
      @fail_transition_guard = options[:fail_transition_guard]
      @log = options[:log]
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
        transitions :to => :closed, :from => [:open], :after => :transitioning, :success => :success_transition do
          guard do
            transition_guard
          end
        end
      end

      event :open, :before => :before, :after => :after do
        transitions :to => :open, :from => :closed
      end
    end

    def log(text)
      puts text if @log
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
    def success_transition; log('success transition'); end

    def before; log('before'); end
    def after; log('after'); end
  end
end
