class CustomEvent < AASM::Core::Event
  attr_reader :custom_method_args

  def custom_event_method!(value)
    @custom_method_args = value
  end

  def some_option
    options[:some_option]
  end

  def another_option
    options[:another_option]
  end

  private

  def dsl_option_keys
    super + [:some_option, :another_option]
  end
end
