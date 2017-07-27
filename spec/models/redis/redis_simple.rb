class RedisSimple
  include Redis::Objects
  include AASM

  value :status

  def id
    1
  end

  aasm :column => :status
  aasm do
    state :alpha, :initial => true
    state :beta
    state :gamma
    event :release do
      transitions :from => [:alpha, :beta, :gamma], :to => :beta
    end
  end
end
