class DoubleDefiner
  include AASM

  aasm do
    state :started
    state :finished

    event :finish do
      transitions :from => :started, :to => :finished
    end

    # simulating a reload
    state :finished, :before_enter => :do_enter
    event :finish do
      transitions :from => :started, :to => :finished, :after => :do_on_transition
    end
  end

  def do_enter; end
  def do_on_transition; end
end
