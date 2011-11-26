module AASM

  module ClassMethods
    def human_event_name(*args)
      warn "AASM.human_event_name is deprecated and will be removed in version 3.1.0; please use AASM.aasm_human_event_name instead!"
      aasm_human_event_name(*args)
    end
  end

  def human_state
    warn "AASM#human_state is deprecated and will be removed in version 3.1.0; please use AASM#aasm_human_state instead!"
    aasm_human_state
  end

end
