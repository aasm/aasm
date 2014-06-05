module AASM
  module Methods
    def self.included(base) #:nodoc:
      base.extend AASM::ClassMethods
      base.send(:include, AASM::InstanceMethods)

      # do not overwrite existing state machines, which could have been created by
      # inheritance, see class method inherited
      AASM::StateMachine[base] ||= AASM::StateMachine.new

      AASM::Persistence.load_persistence(base)
      super
    end
  end
end
