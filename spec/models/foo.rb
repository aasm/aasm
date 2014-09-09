class Foo
  include AASM
  aasm do
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

class FooTwo < Foo
  include AASM
  aasm do
    state :foo
  end
end
