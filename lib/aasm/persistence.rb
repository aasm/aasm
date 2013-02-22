module AASM
  module Persistence
    class << self

      def load_persistence(base)
        # Use a fancier auto-loading thingy, perhaps.  When there are more persistence engines.
        hierarchy = base.ancestors.map {|klass| klass.to_s}

        if hierarchy.include?("ActiveRecord::Base")
          require_files_for('active_record_persistence')
          base.send(:include, AASM::Persistence::ActiveRecordPersistence)
        elsif hierarchy.include?("Mongoid::Document")
          require_files_for('mongoid_persistence')
          base.send(:include, AASM::Persistence::MongoidPersistence)
        end
      end

    private

      def require_files_for(persistence)
        require File.join(File.dirname(__FILE__), 'persistence', 'base')
        require File.join(File.dirname(__FILE__), 'persistence', 'read_state')
        require File.join(File.dirname(__FILE__), 'persistence', persistence)
      end

    end # class << self
  end
end # AASM
