module AASM
  class StateChangeLog < ActiveRecord::Base
    def self.log_state_change(model, options = {})
      create!(
        model_id: model.id,
        model_type: model.class.name,
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
