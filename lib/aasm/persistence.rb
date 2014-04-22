module AASM
  module Persistence
    class << self

      def load_persistence(base)
        # Use a fancier auto-loading thingy, perhaps.  When there are more persistence engines.
        hierarchy = base.ancestors.map {|klass| klass.to_s}

        if hierarchy.include?("ActiveRecord::Base")
          require_files_for(:active_record)
          base.send(:include, AASM::Persistence::ActiveRecordPersistence)
        elsif hierarchy.include?("Mongoid::Document")
          require_files_for(:mongoid)
          base.send(:include, AASM::Persistence::MongoidPersistence)
        elsif hierarchy.include?("Sequel::Model")
          require_files_for(:sequel)
          base.send(:include, AASM::Persistence::SequelPersistence)
        end
      end

    private

      def require_files_for(persistence)
        ['base', "#{persistence}_persistence"].each do |file_name|
          require File.join(File.dirname(__FILE__), 'persistence', file_name)
        end
      end

    end # class << self
  end
end # AASM
