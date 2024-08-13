module Callbacks
  class WithStateArgMultiple

    include AASM

    aasm(:left) do
      state :open, :initial => true
      state :closed
      state :out_to_lunch

      event :close, :before => :before_method, :after => :after_method, :before_success => :before_success_method, :success => :success_method do
        transitions :to => :closed, :from => [:open], :after => :transition_method
        transitions :to => :out_to_lunch, :from => [:open], :after => :transition_method2
      end
    end

    def before_method(arg); end

    def before_success_method(arg); end

    def after_method(arg); end

    def transition_method(arg); end

    def transition_method2(arg); end

    def success_method(arg); end
  end
end
