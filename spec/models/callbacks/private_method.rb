module Callbacks
  class PrivateMethod
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
      state :open, :initial => true
      state :closed

      event :close, :after => :after_event do
        transitions :to => :closed, :from => [:open]
      end

      event :open, :after => :after_event do
        transitions :to => :open, :from => :closed
      end
    end

    def log(text)
      @data << text
      puts text if @log
    end

    def aasm_write_state(*args); log('aasm_write_state'); true; end

    private

    def after_event; log('after_event'); end
  end
end
