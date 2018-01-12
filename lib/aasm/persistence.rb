module AASM
  module Persistence
    class << self

      def load_persistence(base)
        # Use a fancier auto-loading thingy, perhaps.  When there are more persistence engines.
        hierarchy = base.ancestors.map {|klass| klass.to_s}

        if hierarchy.include?("ActiveRecord::Base")
          require_persistence :active_record
          include_persistence base, :active_record
        elsif hierarchy.include?("Mongoid::Document")
          require_persistence :mongoid
          include_persistence base, :mongoid
        elsif hierarchy.include?("NoBrainer::Document")
          require_persistence :no_brainer
          include_persistence base, :no_brainer
        elsif hierarchy.include?("Sequel::Model")
          require_persistence :sequel
          include_persistence base, :sequel
        elsif hierarchy.include?("Dynamoid::Document")
          require_persistence :dynamoid
          include_persistence base, :dynamoid
        elsif hierarchy.include?("Redis::Objects")
          require_persistence :redis
          include_persistence base, :redis
        elsif hierarchy.include?("CDQManagedObject")
          include_persistence base, :core_data_query
        else
          include_persistence base, :plain
        end
      end

      private

      def require_persistence(type)
        require File.join(File.dirname(__FILE__), 'persistence', "#{type}_persistence")
      end

      def include_persistence(base, type)
        base.send(:include, constantize("#{capitalize(type)}Persistence"))
      end

      def capitalize(string_or_symbol)
        string_or_symbol.to_s.split('_').map {|segment| segment[0].upcase + segment[1..-1]}.join('')
      end

      def constantize(string)
        AASM::Persistence.const_get(string)
      end

    end # class << self
  end
end # AASM
