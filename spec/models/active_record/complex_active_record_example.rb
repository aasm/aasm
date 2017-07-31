class ComplexActiveRecordExample < ActiveRecord::Base
  include AASM

  aasm :left, :column => 'left' do
    state :one, :initial => true
    state :two
    state :three

    event :increment do
      transitions :from => :one, :to => :two, guard: :allowed?
      transitions :from => :two, :to => :three
    end
    event :reset do
      transitions :from => :three, :to => :one
    end
  end

  def allowed?
    true
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
