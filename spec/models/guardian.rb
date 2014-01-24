class Guardian
  include AASM

  aasm do
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
  end

  def fail
    false
  end

  def succeed
    true
  end

  def another_succeed
    true
  end

end
