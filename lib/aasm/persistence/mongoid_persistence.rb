module AASM
  module Persistence
    module MongoidPersistence
      # This method:
      #
      # * extends the model with ClassMethods
      # * includes InstanceMethods
      #
      # Adds
      #
      #   before_validation :aasm_ensure_initial_state
      #
      # As a result, it doesn't matter when you define your methods - the following 2 are equivalent
      #
      #   class Foo
      #     include Mongoid::Document
      #     def aasm_write_state(state)
      #       "bar"
      #     end
      #     include AASM
      #   end
      #
      #   class Foo
      #     include Mongoid::Document
      #     include AASM
      #     def aasm_write_state(state)
      #       "bar"
      #     end
      #   end
      #
      def self.included(base)
        base.send(:include, AASM::Persistence::Base)
        base.extend AASM::Persistence::MongoidPersistence::ClassMethods
        base.send(:include, AASM::Persistence::MongoidPersistence::InstanceMethods)

        # Mongoid's Validatable gem dependency goes not have a before_validation_on_xxx hook yet.
        # base.before_validation_on_create :aasm_ensure_initial_state
        base.before_validation :aasm_ensure_initial_state
        # ensure initial aasm state even when validations are skipped
        base.before_create :aasm_ensure_initial_state
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

        def with_state_scope(state)
          with_scope where(aasm_column.to_sym => state.to_s) do
            yield if block_given?
          end
        end

      end

      module InstanceMethods

        # Writes <tt>state</tt> to the state column and persists it to the database
        # using update_attribute (which bypasses validation)
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
          write_attribute(self.class.aasm_column, state.to_s)

          unless self.save(:validate => false)
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
          write_attribute(self.class.aasm_column, state.to_s)
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
          send("#{self.class.aasm_column}=", aasm.enter_initial_state.to_s) if send(self.class.aasm_column).blank?
        end
      end # InstanceMethods

      module NamedScopeMethods
        def aasm_state_with_named_scope name, options = {}
          aasm_state_without_named_scope name, options
          self.named_scope name, :conditions => { "#{table_name}.#{self.aasm_column}" => name.to_s} unless self.respond_to?(name)
        end
      end
    end
  end
end
