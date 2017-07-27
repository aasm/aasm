class RedisComplexExample
  include Redis::Objects
  include AASM

  value :left
  value :right

  def id
    1
  end

  aasm :left, :column => 'left' do
    state :one, :initial => true
    state :two
    state :three

    event :increment do
      transitions :from => :one, :to => :two
      transitions :from => :two, :to => :three
    end
    event :reset do
      transitions :from => :three, :to => :one
    end
  end

  aasm :right, :column => 'right' do
    state :alpha, :initial => true
    state :beta
    state :gamma

    event :level_up do
      transitions :from => :alpha, :to => :beta
      transitions :from => :beta, :to => :gamma
    end
    event :level_down do
      transitions :from => :gamma, :to => :beta
      transitions :from => :beta, :to => :alpha
    end
  end
end
