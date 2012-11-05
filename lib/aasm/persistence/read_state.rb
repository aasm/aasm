module AASM
  module Persistence
    module ReadState

      # Returns the value of the aasm_column - called from <tt>aasm_current_state</tt>
      #
      # If it's a new record, and the aasm state column is blank it returns the initial state
      # (example provided here for ActiveRecord, but it's true for Mongoid as well):
      #
      #   class Foo < ActiveRecord::Base
      #     include AASM
      #     aasm_column :status
      #     aasm_state :opened
      #     aasm_state :closed
      #   end
      #
      #   foo = Foo.new
      #   foo.current_state # => :opened
      #   foo.close
      #   foo.current_state # => :closed
      #
      #   foo = Foo.find(1)
      #   foo.current_state # => :opened
      #   foo.aasm_state = nil
      #   foo.current_state # => nil
      #
      # NOTE: intended to be called from an event
      #
      # This allows for nil aasm states - be sure to add validation to your model
      def aasm_read_state
        if new_record?
          send(self.class.aasm_column).blank? ? aasm_determine_state_name(self.class.aasm_initial_state) : send(self.class.aasm_column).to_sym
        else
          send(self.class.aasm_column).nil? ? nil : send(self.class.aasm_column).to_sym
        end
      end

    end # ReadState
  end # Persistence
end # AASM
