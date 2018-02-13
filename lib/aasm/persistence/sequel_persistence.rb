require 'aasm/persistence/orm'
module AASM
  module Persistence
    module SequelPersistence
      def self.included(base)
        base.send(:include, AASM::Persistence::Base)
        base.send(:include, AASM::Persistence::ORM)
        base.send(:include, AASM::Persistence::SequelPersistence::InstanceMethods)
      end

      module InstanceMethods
        def before_validation
          aasm_ensure_initial_state
          super
        end

        def before_create
          super
        end

        def aasm_raise_invalid_record
          raise Sequel::ValidationFailed.new(self)
        end

        def aasm_new_record?
          new?
        end

        # Returns nil if fails silently
        # http://sequel.jeremyevans.net/rdoc/classes/Sequel/Model/InstanceMethods.html#method-i-save
        def aasm_save
          !save(raise_on_failure: false).nil?
        end

        def aasm_read_attribute(name)
          send(name)
        end

        def aasm_write_attribute(name, value)
          send("#{name}=", value)
        end

        def aasm_transaction(requires_new, requires_lock)
          self.class.db.transaction(savepoint: requires_new) do
            if requires_lock
              # http://sequel.jeremyevans.net/rdoc/classes/Sequel/Model/InstanceMethods.html#method-i-lock-21
              requires_lock.is_a?(String) ? lock!(requires_lock) : lock!
            end
            yield
          end
        end

        def aasm_update_column(attribute_name, value)
          this.update(attribute_name => value)
        end

        # Ensures that if the aasm_state column is nil and the record is new
        # that the initial state gets populated before validation on create
        #
        #   foo = Foo.new
        #   foo.aasm_state # => nil
        #   foo.valid?
        #   foo.aasm_state # => "open" (where :open is the initial state)
        #
        #
        #   foo = Foo.find(:first)
        #   foo.aasm_state # => 1
        #   foo.aasm_state = nil
        #   foo.valid?
        #   foo.aasm_state # => nil
        #
        def aasm_ensure_initial_state
          AASM::StateMachineStore.fetch(self.class, true).machine_names.each do |state_machine_name|
            aasm(state_machine_name).enter_initial_state if
              (new? || values.key?(self.class.aasm(state_machine_name).attribute_name)) &&
                send(self.class.aasm(state_machine_name).attribute_name).to_s.strip.empty?
          end
        end

      end
    end
  end
end
