module AASM
  class StateChangeLog < ActiveRecord::Base

    self.table_name = 'aasm_state_change_logs'
    belongs_to :model, polymorphic: true

    def self.log_state_change(model, options = {})
      create!(
        model: model,
        from_state: options[:from_state],
        to_state: options[:to_state],
        transition_event: options[:transition_event],
        reason_id: options[:reason_id],
        comment: options[:comment],
        user_id: options[:user_id]
      )
    end
  end
end
