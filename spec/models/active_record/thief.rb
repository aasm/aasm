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

class MultipleThief < ActiveRecord::Base
  if ActiveRecord::VERSION::MAJOR >= 3
    self.table_name = 'multiple_thieves'
  else
    set_table_name "multiple_thieves"
  end
  include AASM
  aasm :left, :column => :aasm_state do
    state :rich
    state :jailed
    initial_state Proc.new {|thief| thief.skilled ? :rich : :jailed }
  end
  attr_accessor :skilled, :aasm_state
end
