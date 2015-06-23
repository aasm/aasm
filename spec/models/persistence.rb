class Gate < ActiveRecord::Base
  include AASM

  # Fake this column for testing purposes
  # attr_accessor :aasm_state

  def value
    'value'
  end

  aasm do
    state :opened
    state :closed

    event :view do
      transitions :to => :read, :from => [:needs_attention]
    end
  end
end

class FalseState < ActiveRecord::Base
  include AASM

  def initialize(*args)
    super
    self.aasm_state = false
  end

  aasm do
    state :opened
    state :closed

    event :view do
      transitions :to => :read, :from => [:needs_attention]
    end
  end
end

class Card < ActiveRecord::Base
  include AASM
  enum status: {
    default: 0,
    published: 1,
    deleted: 2
  }

  aasm column: :status, enum: true, skip_validation_on_save: true, no_direct_assignment: true do
    state :default, initial: true
    state :published
    state :deleted

    event :publish do
      transitions from: :default, to: :published
    end

    event :delete do
      transitions from: :published, to: :deleted
    end
  end
end

class WithEnum < ActiveRecord::Base
  include AASM

  # Fake this column for testing purposes
  attr_accessor :aasm_state

  def self.test
    {}
  end

  aasm :enum => :test do
    state :opened
    state :closed

    event :view do
      transitions :to => :read, :from => [:needs_attention]
    end
  end
end

class WithTrueEnum < ActiveRecord::Base
  include AASM

  # Fake this column for testing purposes
  attr_accessor :aasm_state

  def value
    'value'
  end

  aasm :enum => true do
    state :opened
    state :closed

    event :view do
      transitions :to => :read, :from => [:needs_attention]
    end
  end
end

class WithFalseEnum < ActiveRecord::Base
  include AASM

  # Fake this column for testing purposes
  attr_accessor :aasm_state

  aasm :enum => false do
    state :opened
    state :closed

    event :view do
      transitions :to => :read, :from => [:needs_attention]
    end
  end
end

class Reader < ActiveRecord::Base
  include AASM

  def aasm_read_state
    "fi"
  end
end

class Writer < ActiveRecord::Base
  def aasm_write_state(state)
    "fo"
  end
  include AASM
end

class Transient < ActiveRecord::Base
  def aasm_write_state_without_persistence(state)
    "fum"
  end
  include AASM
end

class SimpleNewDsl < ActiveRecord::Base
  include AASM
  aasm :column => :status
  aasm do
    state :unknown_scope
    state :new
  end
end

class NoScope < ActiveRecord::Base
  include AASM
  aasm :create_scopes => false do
    state :pending, :initial => true
    state :running
    event :run do
      transitions :from => :pending, :to => :running
    end
  end
end

class NoDirectAssignment < ActiveRecord::Base
  include AASM
  aasm :no_direct_assignment => true do
    state :pending, :initial => true
    state :running
    event :run do
      transitions :from => :pending, :to => :running
    end
  end
end

class DerivateNewDsl < SimpleNewDsl
end

class Thief < ActiveRecord::Base
  if ActiveRecord::VERSION::MAJOR >= 3
    self.table_name = 'thieves'
  else
    set_table_name "thieves"
  end
  include AASM
  aasm do
    state :rich
    state :jailed
    initial_state Proc.new {|thief| thief.skilled ? :rich : :jailed }
  end
  attr_accessor :skilled, :aasm_state
end
