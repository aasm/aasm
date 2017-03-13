class WrongArgumentsList
  include AASM
  aasm do
    state :new, :reviewed, :finalized

    event :mark_as_reviewed,
          :guard => proc { |*args| arguments_list(*args) } do
      transitions :from => :new, :to => :reviewed
    end
  end

  def arguments_list(arg1, arg2)
    if arg1.nil?
      puts "everything is ok"
    end
  end
end
