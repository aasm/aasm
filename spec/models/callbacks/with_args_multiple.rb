module Callbacks
  class WithArgsMultiple
    include AASM

    def initialize(options={})
      @log = options[:log]
      reset_data
    end

    def reset_data
      @data = []
    end

    def data
      @data.join(' ')
    end

    aasm(:left) do
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
      @data << text
      puts text if @log
    end

    def aasm_write_state(*args); log('aasm_write_state'); true; end

    def before_enter_open(*args); log("before_enter_open(#{args.map(&:inspect).join(',')})"); end
    def before_exit_open(*args); log("before_exit_open(#{args.map(&:inspect).join(',')})"); end
    def after_enter_open(*args); log("after_enter_open(#{args.map(&:inspect).join(',')})"); end
    def after_exit_open(*args); log("after_exit_open(#{args.map(&:inspect).join(',')})"); end

    def before_enter_closed(*args); log("before_enter_closed(#{args.map(&:inspect).join(',')})"); end
    def before_exit_closed(*args); log("before_enter_closed(#{args.map(&:inspect).join(',')})"); end
    def after_enter_closed(*args); log("after_enter_closed(#{args.map(&:inspect).join(',')})"); end
    def after_exit_closed(*args); log("after_exit_closed(#{args.map(&:inspect).join(',')})"); end

    def before(arg1, *args); log("before(#{arg1.inspect},#{args.map(&:inspect).join(',')})"); end
    def transition_proc(arg1, arg2); log("transition_proc(#{arg1.inspect},#{arg2.inspect})"); end
    def after(*args); log("after(#{args.map(&:inspect).join(',')})"); end
  end
end
