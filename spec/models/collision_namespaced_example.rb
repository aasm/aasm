class CollisionNamespacedExample
  include AASM

  aasm(:work, namespace: :work) do
    state :idle, :initial => true
    state :running

    event :start do
      transitions :from => :idle, :to => :running
    end

    event :stop do
      transitions :from => :running, :to => :idle
    end
  end

  aasm(:engine, namespace: :engine) do
    state :idle, :initial => true
    state :running

    event :start do
      transitions :from => :idle, :to => :running
    end

    event :stop do
      transitions :from => :running, :to => :idle
    end
  end
end
