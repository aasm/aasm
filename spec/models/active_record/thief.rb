class Thief < ActiveRecord::Base
  self.table_name = 'thieves'

  include AASM
  aasm do
    state :rich
    state :jailed
    initial_state Proc.new {|thief| thief.skilled ? :rich : :jailed }
  end
  attr_accessor :skilled, :aasm_state
end

class MultipleThief < ActiveRecord::Base
  self.table_name = 'multiple_thieves'

  include AASM
  aasm :left, :column => :aasm_state do
    state :rich
    state :jailed
    initial_state Proc.new {|thief| thief.skilled ? :rich : :jailed }
  end
  attr_accessor :skilled, :aasm_state
end
