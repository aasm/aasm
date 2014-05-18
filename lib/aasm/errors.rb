module AASM
  class InvalidTransition < RuntimeError; end
  class UndefinedState < RuntimeError; end
  class NoDirectAssignmentError < RuntimeError; end
end
