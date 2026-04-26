# frozen_string_literal: true

class CallbackWithOptionalKeywordArguments
  def initialize(state_machine, my_optional_arg: nil, **_args)
    @state_machine = state_machine
    @my_optional_arg = my_optional_arg
  end

  def call
    @state_machine.my_attribute = @my_optional_arg if @my_optional_arg
  end
end

class CallbackWithRequiredKeywordArguments
  def initialize(state_machine, my_required_arg:)
    @state_machine = state_machine
    @my_required_arg = my_required_arg
  end

  def call
    @state_machine.my_attribute = @my_required_arg
  end
end

class ClassWithKeywordArguments
  include AASM
  
  aasm do
    state :open, :initial => true, :column => :status
    state :closed
  
    event :close_forever do
      before :_before_close
      transitions from: :open,
                  to: :closed
    end

    event :close_temporarily do
      before :_before_close
      transitions from: :open,
                  to: :closed,
                  after: [CallbackWithOptionalKeywordArguments]
    end

    event :close_then_something_else do
      before :_before_close
      transitions from: :open,
                  to: :closed,
                  after: [CallbackWithRequiredKeywordArguments, CallbackWithRequiredKeywordArguments]
    end
  end


  def _before_close
    @my_attribute = "closed_forever"
  end

  attr_accessor :my_attribute
end