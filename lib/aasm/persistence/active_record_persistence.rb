module AASM
  module Persistence
    module ActiveRecordPersistence
      # This method:
      #
      # * extends the model with ClassMethods
      # * includes InstanceMethods
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
        base.send(:include, AASM::Persistence::Base)
        base.extend AASM::Persistence::ActiveRecordPersistence::ClassMethods
        base.send(:include, AASM::Persistence::ActiveRecordPersistence::InstanceMethods)

        if ActiveRecord::VERSION::MAJOR >= 3
          base.before_validation(:aasm_ensure_initial_state, :on => :create)
        else
          base.before_validation_on_create(:aasm_ensure_initial_state)
        end

        # ensure initial aasm state even when validations are skipped
        base.before_create(:aasm_ensure_initial_state)

        # ensure state is in the list of states
        base.validate :aasm_validate_states
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

        # Writes <tt>state</tt> to the state column and persists it to the database
        #
        #   foo = Foo.find(1)
        #   foo.aasm.current_state # => :opened
        #   foo.close!
        #   foo.aasm.current_state # => :closed
        #   Foo.find(1).aasm.current_state # => :closed
        #
        # NOTE: intended to be called from an event
        def aasm_write_state(state)
          old_value = read_attribute(self.class.aasm_column)
          aasm_write_attribute state

          success = if aasm_skipping_validations
            value = aasm_raw_attribute_value state
            self.class.where(self.class.primary_key => self.id).update_all(self.class.aasm_column => value) == 1
          else
            self.save
          end
          unless success
            write_attribute(self.class.aasm_column, old_value)
            return false
          end

          true
        end

        # Writes <tt>state</tt> to the state column, but does not persist it to the database
        #
        #   foo = Foo.find(1)
        #   foo.aasm.current_state # => :opened
        #   foo.close
        #   foo.aasm.current_state # => :closed
        #   Foo.find(1).aasm.current_state # => :opened
        #   foo.save
        #   foo.aasm.current_state # => :closed
        #   Foo.find(1).aasm.current_state # => :closed
        #
        # NOTE: intended to be called from an event
        def aasm_write_state_without_persistence(state)
          aasm_write_attribute state
        end

      private
        def aasm_enum
          case AASM::StateMachine[self.class].config.enum
            when false then nil
            when true then aasm_guess_enum_method
            when nil then aasm_guess_enum_method if aasm_column_looks_like_enum
            else AASM::StateMachine[self.class].config.enum
          end
        end

        def aasm_column_looks_like_enum
          self.class.columns_hash[self.class.aasm_column.to_s].type == :integer
        end

        def aasm_guess_enum_method
          self.class.aasm_column.to_s.pluralize.to_sym
        end

        def aasm_skipping_validations
          AASM::StateMachine[self.class].config.skip_validation_on_save
        end

        def aasm_write_attribute(state)
          write_attribute self.class.aasm_column, aasm_raw_attribute_value(state)
        end

        def aasm_raw_attribute_value(state)
          if aasm_enum
            value = self.class.send(aasm_enum)[state]
          else
            value = state.to_s
          end
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
          aasm.enter_initial_state if send(self.class.aasm_column).blank?
        end

        def aasm_fire_event(name, options, *args, &block)
          success = options[:persist] ? self.class.transaction(:requires_new => requires_new?) { super } : super

          if success && options[:persist]
            new_state = aasm.state_object_for_name(aasm.current_state)
            new_state.fire_callbacks(:after_commit, self)
          end

          success
        end

        def requires_new?
          AASM::StateMachine[self.class].config.requires_new_transaction
        end

        def aasm_validate_states
          unless AASM::StateMachine[self.class].config.skip_validation_on_save
            if aasm.current_state && !aasm.states.include?(aasm.current_state)
              self.errors.add(AASM::StateMachine[self.class].config.column , "is invalid")
            end
          end
        end
      end # InstanceMethods

    end
  end
end
