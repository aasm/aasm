class SimpleExampleWithGuardArgs
  include AASM
  aasm do
    state :initialised, :initial => true
    state :filled_out_with_args

    event :fill_out_with_args do
      transitions :guard => [:arg_is_valid?],
                  :from => :initialised,
                  :to => :filled_out_with_args
    end
  end

  def arg_is_valid?(arg)
    return arg
  end
end
