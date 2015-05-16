class Reader < ActiveRecord::Base
  include AASM

  def aasm_read_state
    "fi"
  end
end
