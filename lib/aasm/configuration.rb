module AASM
  class Configuration
    # for all persistence layers: which database column to use?
    attr_accessor :column

    # let's cry if the transition is invalid
    attr_accessor :whiny_transitions

    # for all persistence layers: create named scopes for each state
    attr_accessor :create_scopes

    # for ActiveRecord: when the model is invalid, true -> raise, false -> return false
    attr_accessor :whiny_persistence

    # for ActiveRecord: store the new state even if the model is invalid and return true
    attr_accessor :skip_validation_on_save

    # for ActiveRecord: use requires_new for nested transactions?
    attr_accessor :requires_new_transaction

    # for ActiveRecord: use pessimistic locking
    attr_accessor :requires_lock

    # forbid direct assignment in aasm_state column (in ActiveRecord)
    attr_accessor :no_direct_assignment

    # allow a AASM::Base sub-class to be used for state machine
    attr_accessor :with_klass

    attr_accessor :enum

    # namespace reader methods and constants
    attr_accessor :namespace

    # Configure a logger, with default being a Logger to STDERR
    attr_accessor :logger

    # These are the methods that will be override in a sub-class.
    attr_accessor :override_methods

    # Ignore all warnings, to be used at your own risk.
    attr_accessor :ignore_override_warnings
  end
end
