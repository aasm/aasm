class Bar
  include AASM

  aasm do
    state :read
    state :ended

    event :foo do
      transitions :to => :ended, :from => [:read]
    end
  end
end

class Baz < Bar
end
