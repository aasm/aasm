class CustomAASMBase < AASM::Base
  # A custom transiton that we want available across many AASM models.
  def count_transitions!
    klass.class_eval do
      aasm :with_klass => CustomAASMBase do
        after_all_transitions :increment_transition_count
      end
    end
  end

  # A custom annotation that we want available across many AASM models.
  def requires_guards!
    klass.class_eval do
      attr_reader :authorizable_called,
        :transition_count,
        :fillable_called

      def authorizable?
        @authorizable_called = true
      end

      def fillable?
        @fillable_called = true
      end

      def increment_transition_count
        @transition_count ||= 0
        @transition_count += 1
      end
    end
  end
end

class SimpleCustomExample
  include AASM

  # Let's build an AASM state machine with our custom class.
  aasm :with_klass => CustomAASMBase do
    requires_guards!
    count_transitions!

    state :initialised, :initial => true
    state :filled_out
    state :authorised

    event :fill_out do
      transitions :from => :initialised, :to => :filled_out, :guard => :fillable?
    end
    event :authorise do
      transitions :from => :filled_out, :to => :authorised, :guard => :authorizable?
    end
  end
end
