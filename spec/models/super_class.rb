class SuperClass
  include AASM

  aasm do
    state :read
    state :ended

    event :foo do
      transitions :to => :ended, :from => [:read]
    end
  end

  def update_state
    if may_foo?
      foo!
    end
  end
end
