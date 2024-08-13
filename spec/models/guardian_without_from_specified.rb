class GuardianWithoutFromSpecified
  include AASM

  aasm do
    state :alpha, :initial => true
    state :beta
    state :gamma

    event :use_guards_where_the_first_fails do
      transitions :to => :beta,  :guard => :fail
      transitions :to => :gamma, :guard => :succeed
    end
  end


  def fail; false; end
  def succeed; true; end
end
