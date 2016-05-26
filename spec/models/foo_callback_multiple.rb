class FooCallbackMultiple
  include AASM

  aasm(:left) do
    state :open, :initial => true, :before_exit => :before_exit
    state :closed, :before_enter => :before_enter
    state :final

    event :close, :success => :success_callback do
      transitions :from => [:open], :to => [:closed]
    end

    event :null do
      transitions :from => [:open], :to => [:closed, :final], :guard => :always_false
    end
  end

  aasm(:right, :column => :right) do
    state :green, :initial => true
    state :yellow
    state :red

    event :green do
      transitions :from => [:yellow], :to => :green
    end
    event :yellow do
      transitions :from => [:green, :red], :to => :yellow
    end
    event :red do
      transitions :from => [:yellow], :to => :red
    end
  end

  def always_false
    false
  end

  def success_callback
  end

  def before_enter
  end
  def before_exit
  end
end
