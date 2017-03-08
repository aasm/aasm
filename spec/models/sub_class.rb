require_relative 'super_class'

class SubClass < SuperClass
  # Add an after callback that is not defined in the parent
  aasm.state_machine.events[:foo].options[:after] = [:after_foo_event]

  # Add global callback that is not defined in the parent
  aasm.state_machine.global_callbacks[:after_all_transitions] = :after_all_event

  attr_accessor :called_after

  def after_foo_event
    self.called_after = true
  end

  def after_all_event; end
end

class SubClassMultiple < SuperClassMultiple
  # Add after callbacks that are not defined in the parent
  aasm(:left).state_machine.events[:foo].options[:after] = [:left_after_foo_event]
  aasm(:right).state_machine.events[:close].options[:after] = [:right_after_close_event]

  # Add global callback that is not defined in the parent
  aasm(:left).state_machine.global_callbacks[:after_all_transitions] = :left_after_all_event
  aasm(:right).state_machine.global_callbacks[:after_all_transitions] = :right_after_all_event

  attr_accessor :left_called_after, :right_called_after

  def left_after_foo_event
    self.left_called_after = true
  end

  def right_after_close_event
    self.right_called_after = true
  end

  def left_after_all_event; end

  def right_after_all_event; end
end
