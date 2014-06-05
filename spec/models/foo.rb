class Foo
  include AASM::Methods
  aasm do
    state :open, :initial => true, :exit => :exit
    state :closed, :enter => :enter

    event :close, :success => :success_callback do
      transitions :from => [:open], :to => [:closed]
    end

    event :null do
      transitions :from => [:open], :to => :closed, :guard => :always_false
    end
  end

  def always_false
    false
  end

  def success_callback
  end

  def enter
  end
  def exit
  end
end

class FooTwo < Foo
  include AASM::Methods
  aasm do
    state :foo
  end
end
