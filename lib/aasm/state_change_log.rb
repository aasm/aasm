module AASM
  class StateChangeLog < ActiveRecord::Base

    self.table_name = 'aasm_state_change_logs'
    belongs_to :model, polymorphic: true

  end
end
