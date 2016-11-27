class SimpleExample
  include AASM
  aasm do
    state :initialised, :initial => true
    state :filled_out
    state :authorised

    event :fill_out do
      transitions :from => :initialised, :to => :filled_out
    end
    event :authorise do
      transitions :from => :filled_out, :to => :authorised
    end

    event :fill_out_with_args do
      transitions :guard => [:arg_is_valid?],
                  :from => :initialised,
                  :to => :filled_out
    end
  end

  def arg_is_valid?(arg)
    return arg
  end
end
