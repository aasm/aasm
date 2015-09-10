require_relative 'super_class'

class SubClassWithMoreStates < SuperClass
  include AASM
  aasm do
    state :foo
  end
end

class SubClassWithMoreStatesMultiple < SuperClassMultiple
  include AASM
  aasm(:left) do
    state :foo
  end
  aasm(:right) do
    state :archived
  end
end
