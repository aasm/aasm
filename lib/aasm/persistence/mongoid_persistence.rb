require 'aasm/persistence/orm'
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
        base.send(:include, AASM::Persistence::ORM)
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

        private

        def aasm_save
          self.save
        end

        def aasm_raise_invalid_record
          raise Mongoid::Errors::Validations.new(self)
        end

        def aasm_supports_transactions?
          false
        end

        def aasm_update_column(attribute_name, value)
          if Mongoid::VERSION.to_f >= 4
            set(Hash[attribute_name, value])
          else
            set(attribute_name, value)
          end

          true
        end

        def aasm_read_attribute(name)
          read_attribute(name)
        end

        def aasm_write_attribute(name, value)
          write_attribute(name, value)
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
            attribute_name = self.class.aasm(state_machine_name).attribute_name.to_s
            # Do not load initial state when object attributes are not loaded,
            # mongoid has_many relationship does not load child object attributes when
            # only ids are loaded, for example parent.child_ids will not load child object attributes.
            # This feature is introduced in mongoid > 4.
            if attribute_names.include?(attribute_name) && !attributes[attribute_name] || attributes[attribute_name].empty?
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
