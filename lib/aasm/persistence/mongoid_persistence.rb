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
        base.send(:include, AASM::Persistence::MongoidPersistence::InstanceMethods)
        base.extend AASM::Persistence::MongoidPersistence::ClassMethods

        base.after_initialize :aasm_ensure_initial_state
      end

      module ClassMethods
        def aasm_create_scope(state_machine_name, scope_name)
          scope_options = lambda {
            send(
              :where,
              { aasm(state_machine_name).attribute_name.to_sym => scope_name.to_s }
            )
          }
          send(:scope, scope_name, scope_options)
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
        def aasm_write_state(state, name=:default)
          old_value = read_attribute(self.class.aasm(name).attribute_name)
          write_attribute(self.class.aasm(name).attribute_name, state.to_s)

          unless self.save(:validate => false)
            write_attribute(self.class.aasm(name).attribute_name, old_value)
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
        def aasm_write_state_without_persistence(state, name=:default)
          write_attribute(self.class.aasm(name).attribute_name, state.to_s)
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
          AASM::StateMachineStore.fetch(self.class, true).machine_names.each do |state_machine_name|
            attribute_name = self.class.aasm(state_machine_name).attribute_name.to_s
            # Do not load initial state when object attributes are not loaded,
            # mongoid has_many relationship does not load child object attributes when
            # only ids are loaded, for example parent.child_ids will not load child object attributes.
            # This feature is introduced in mongoid > 4.
            if attribute_names.include?(attribute_name) && attributes[attribute_name].blank?
              # attribute_missing? is defined in mongoid > 4
              return if Mongoid::VERSION.to_f >= 4 && attribute_missing?(attribute_name)
              send("#{self.class.aasm(state_machine_name).attribute_name}=", aasm(state_machine_name).enter_initial_state.to_s)
            end
          end
        end
      end # InstanceMethods

      # module NamedScopeMethods
      #   def aasm_state_with_named_scope name, options = {}
      #     aasm_state_without_named_scope name, options
      #     self.named_scope name, :conditions => { "#{table_name}.#{self.aasm.attribute_name}" => name.to_s} unless self.respond_to?(name)
      #   end
      # end
    end
  end # Persistence
end # AASM
