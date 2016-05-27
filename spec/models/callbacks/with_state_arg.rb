module Callbacks
  class WithStateArg

    include AASM

    aasm do
      state :open, :initial => true
      state :closed
      state :out_to_lunch

      event :close, :before => :before_method, :after => :after_method do
        transitions :to => :closed, :from => [:open], :after => :transition_method, :success => :success_method
        transitions :to => :out_to_lunch, :from => [:open], :after => :transition_method2, :success => :success_method2
      end
    end

    def before_method(arg); end

    def after_method(arg); end

    def transition_method(arg); end

    def transition_method2(arg); end

    def success_method(arg); end

    def success_method2(arg); end

  end
end
