module AASM
  module Persistence
    module ActiveRecordPersistence
      # This method:
      #
      # * extends the model with ClassMethods
      # * includes InstanceMethods
      #
      # Unless the corresponding methods are already defined, it includes
      # * ReadState
      # * WriteState
      # * WriteStateWithoutPersistence
      #
      # Adds
      #
      #   before_validation :aasm_ensure_initial_state, :on => :create
      #
      # As a result, it doesn't matter when you define your methods - the following 2 are equivalent
      #
      #   class Foo < ActiveRecord::Base
      #     def aasm_write_state(state)
      #       "bar"
      #     end
      #     include AASM
      #   end
      #
      #   class Foo < ActiveRecord::Base
      #     include AASM
      #     def aasm_write_state(state)
      #       "bar"
      #     end
      #   end
      #
      def self.included(base)
        base.extend AASM::Persistence::Base::ClassMethods
        base.extend AASM::Persistence::ActiveRecordPersistence::ClassMethods
        base.send(:include, AASM::Persistence::ActiveRecordPersistence::InstanceMethods)
        base.send(:include, AASM::Persistence::ReadState) unless base.method_defined?(:aasm_read_state)
        base.send(:include, AASM::Persistence::ActiveRecordPersistence::WriteState) unless base.method_defined?(:aasm_write_state)
        base.send(:include, AASM::Persistence::ActiveRecordPersistence::WriteStateWithoutPersistence) unless base.method_defined?(:aasm_write_state_without_persistence)

        if ActiveRecord::VERSION::MAJOR >= 3
          base.before_validation(:aasm_ensure_initial_state, :on => :create)
        else
          base.before_validation_on_create(:aasm_ensure_initial_state)
        end
      end

      module ClassMethods

        def find_in_state(number, state, *args)
          with_state_scope state do
            find(number, *args)
          end
        end

        def count_in_state(state, *args)
          with_state_scope state do
            count(*args)
          end
        end

        def calculate_in_state(state, *args)
          with_state_scope state do
            calculate(*args)
          end
        end

        protected
        def with_state_scope(state)
          with_scope :find => {:conditions => ["#{table_name}.#{aasm_column} = ?", state.to_s]} do
            yield if block_given?
          end
        end
      end

      module InstanceMethods

        # Returns the current aasm_state of the object.  Respects reload and
        # any changes made to the aasm_state field directly
        #
        # Internally just calls <tt>aasm_read_state</tt>
        #
        #   foo = Foo.find(1)
        #   foo.aasm_current_state # => :pending
        #   foo.aasm_state = "opened"
        #   foo.aasm_current_state # => :opened
        #   foo.close # => calls aasm_write_state_without_persistence
        #   foo.aasm_current_state # => :closed
        #   foo.reload
        #   foo.aasm_current_state # => :pending
        #
        def aasm_current_state
          @current_state = aasm_read_state
        end

        private

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
          aasm_enter_initial_state if send(self.class.aasm_column).blank?
        end

        def aasm_fire_event(name, options, *args)
          transaction do
            super
          end
        end

      end

      module WriteStateWithoutPersistence
        # Writes <tt>state</tt> to the state column, but does not persist it to the database
        #
        #   foo = Foo.find(1)
        #   foo.aasm_current_state # => :opened
        #   foo.close
        #   foo.aasm_current_state # => :closed
        #   Foo.find(1).aasm_current_state # => :opened
        #   foo.save
        #   foo.aasm_current_state # => :closed
        #   Foo.find(1).aasm_current_state # => :closed
        #
        # NOTE: intended to be called from an event
        def aasm_write_state_without_persistence(state)
          write_attribute(self.class.aasm_column, state.to_s)
        end
      end

      module WriteState
        # Writes <tt>state</tt> to the state column and persists it to the database
        #
        #   foo = Foo.find(1)
        #   foo.aasm_current_state # => :opened
        #   foo.close!
        #   foo.aasm_current_state # => :closed
        #   Foo.find(1).aasm_current_state # => :closed
        #
        # NOTE: intended to be called from an event
        def aasm_write_state(state)
          old_value = read_attribute(self.class.aasm_column)
          write_attribute(self.class.aasm_column, state.to_s)

          success = if AASM::StateMachine[self.class].config.skip_validation_on_save
            self.class.update_all({ self.class.aasm_column => state.to_s }, self.class.primary_key => self.id) == 1
          else
            self.save
          end
          unless success
            write_attribute(self.class.aasm_column, old_value)
            return false
          end

          true
        end
      end

    end
  end
end
