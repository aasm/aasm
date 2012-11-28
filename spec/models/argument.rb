class Argument
  include AASM
  aasm do
    state :invalid, :initial => true
    state :valid

    event :valid do
      transitions :to => :valid, :from => [:invalid]
    end
  end
end
