class GuardianMultiple
  include AASM

  aasm(:left) do
    state :alpha, :initial => true
    state :beta

    event :use_one_guard_that_succeeds do
      transitions :from => :alpha, :to => :beta, :guard => :succeed
    end
    event :use_one_guard_that_fails do
      transitions :from => :alpha, :to => :beta, :guard => :fail
    end

    event :use_guards_that_succeed do
      transitions :from => :alpha, :to => :beta, :guards => [:succeed, :another_succeed]
    end
    event :use_guards_where_the_first_fails do
      transitions :from => :alpha, :to => :beta, :guards => [:succeed, :fail]
    end
    event :use_guards_where_the_second_fails do
      transitions :from => :alpha, :to => :beta, :guards => [:fail, :succeed]
    end

    event :use_event_guards_that_succeed, :guards => [:succeed, :another_succeed] do
      transitions :from => :alpha, :to => :beta
    end
    event :use_event_and_transition_guards_that_succeed, :guards => [:succeed, :another_succeed] do
      transitions :from => :alpha, :to => :beta, :guards => [:more_succeed]
    end
    event :use_event_guards_where_the_first_fails, :guards => [:succeed, :fail] do
      transitions :from => :alpha, :to => :beta
    end
    event :use_event_guards_where_the_second_fails, :guards => [:fail, :succeed] do
      transitions :from => :alpha, :to => :beta, :guard => :another_succeed
    end
    event :use_event_and_transition_guards_where_third_fails, :guards => [:succeed, :another_succeed] do
      transitions :from => :alpha, :to => :beta, :guards => [:fail]
    end
  end

  def fail; false; end

  def succeed; true; end
  def another_succeed; true; end
  def more_succeed; true; end

end
