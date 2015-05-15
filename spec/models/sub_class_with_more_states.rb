require_relative 'super_class'
class SubClassWithMoreStates < SuperClass
  include AASM
  aasm do
    state :foo
  end
end
