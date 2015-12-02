class StatesOnOneLineExample
  include AASM

  aasm :one_line do
    state :initial, :initial => true
    state :first, :second
  end
end
