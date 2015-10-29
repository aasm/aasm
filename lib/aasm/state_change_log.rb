module AASM
  class StateChangeLog < ActiveRecord::Base
    def self.log_state_change(model, event_name, old_state, new_state)
      create!(
        model_id: model.id,
        model_type: model.class.name,
        from_state: old_state,
        to_state: new_state,
        transition_event: event_name
      )
    end
  end
end
