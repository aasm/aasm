module AASM
  module Persistence
    module ActiveRecordPersistence
      def self.included(base)
        base.extend AASM::Persistence::ActiveRecordPersistence::ClassMethods
        base.send(:include, AASM::Persistence::ActiveRecordPersistence::WriteState) unless base.method_defined?(:aasm_write_state)
        base.send(:include, AASM::Persistence::ActiveRecordPersistence::ReadState) unless base.method_defined?(:aasm_read_state)
      end

      module ClassMethods
        def aasm_column(column_name=nil)
          if column_name
            @aasm_column = column_name.to_sym
          else
            @aasm_column
          end
        end
      end

      module WriteState
        def aasm_write_state(state)
          @aasm_column ||= :aasm_state
          
          update_attribute(@aasm_column, state.to_s)
        end
      end

      module ReadState
        def aasm_read_state
          @aasm_column ||= :aasm_state
          send(@aasm_column).to_sym
        end
      end
    end
  end
end
