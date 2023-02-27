class CustomState < AASM::Core::State

  def custom_state_method(value)
    value * value
  end
end
