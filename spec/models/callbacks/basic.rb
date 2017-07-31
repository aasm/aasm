module Callbacks
  class Basic
    include AASM

    def initialize(options={})
      @fail_event_guard = options[:fail_event_guard]
      @fail_transition_guard = options[:fail_transition_guard]
      @log = options[:log]
      reset_data
    end

    def reset_data
      @data = []
    end

    def data
      @data.join(' ')
    end

    aasm do
      before_all_events       :before_all_events
      after_all_events        :after_all_events
      ensure_on_all_events    :ensure_on_all_events
      after_all_transitions   :after_all_transitions

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

      event :close,
            :before => :before_event,
            :after => :after_event,
            :guard => :event_guard,
            :before_success => :event_before_success,
            :ensure => :ensure_event do
        transitions :to => :closed, :from => [:open],
                    :guard => :transition_guard,
                    :after => :after_transition,
                    :success => :success_transition
      end

      event :open, :before => :before_event, :after => :after_event  do
        transitions :to => :open, :from => :closed
      end
    end

    def log(text)
      @data << text
      puts text if @log
    end

    def aasm_write_state(*args);  log('aasm_write_state'); true;  end
    def before_enter_open;        log('before_enter_open');       end
    def enter_open;               log('enter_open');              end
    def before_exit_open;         log('before_exit_open');        end
    def after_enter_open;         log('after_enter_open');        end
    def exit_open;                log('exit_open');               end
    def after_exit_open;          log('after_exit_open');         end

    def before_enter_closed;      log('before_enter_closed'); end
    def enter_closed;             log('enter_closed');        end
    def before_exit_closed;       log('before_exit_closed');  end
    def exit_closed;              log('exit_closed');         end
    def after_enter_closed;       log('after_enter_closed');  end
    def after_exit_closed;        log('after_exit_closed');   end

    def event_guard;              log('event_guard');         !@fail_event_guard;      end
    def transition_guard;         log('transition_guard');    !@fail_transition_guard; end

    def event_before_success;     log('event_before_success'); end

    def after_transition;         log('after_transition');        end
    def after_all_transitions;    log('after_all_transitions');   end

    def before_all_events;        log('before_all_events')    end
    def before_event;             log('before_event');        end
    def after_event;              log('after_event');         end
    def after_all_events;         log('after_all_events');    end

    def after_transition;         log('after_transition');    end
    def success_transition;       log('transition_success');  end

    def ensure_event;             log('ensure');              end
    def ensure_on_all_events;     log('ensure');              end
  end
end
