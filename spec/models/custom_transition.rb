class CustomTransition < AASM::Core::Transition
  attr_reader :custom_method_args

  def custom_transition_method!(value)
    @custom_method_args = value
  end

  def some_option
    opts[:some_option]
  end

  def another_option
    options[:another_option]
  end

  private

  def dsl_option_keys
    super + [:some_option, :another_option]
  end
end
