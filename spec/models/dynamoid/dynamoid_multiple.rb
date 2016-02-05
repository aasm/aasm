class DynamoidMultiple
  include Dynamoid::Document
  include AASM

  field :status

  attr_accessor :default

  aasm :left, :column => :status
  aasm :left do
    state :alpha, :initial => true
    state :beta
    state :gamma
    event :release do
      transitions :from => [:alpha, :beta, :gamma], :to => :beta
    end
  end
end
