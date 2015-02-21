module AASM
  module Persistence
    class << self

      def load_persistence(base)
        # Use a fancier auto-loading thingy, perhaps.  When there are more persistence engines.
        hierarchy = base.ancestors.map {|klass| klass.to_s}

        if hierarchy.include?("ActiveRecord::Base")
          include_persistence base, :active_record
        elsif hierarchy.include?("Mongoid::Document")
          include_persistence base, :mongoid
        elsif hierarchy.include?("MongoMapper::Document")
          include_persistence base, :mongo_mapper
        elsif hierarchy.include?("Sequel::Model")
          include_persistence base, :sequel
        else
          include_persistence base, :plain
        end
      end

      private

      def include_persistence(base, type)
        require File.join(File.dirname(__FILE__), 'persistence', "#{type}_persistence")
        base.send(:include, constantize("AASM::Persistence::#{capitalize(type)}Persistence"))
      end

      def capitalize(string_or_symbol)
        string_or_symbol.to_s.split('_').map {|segment| segment[0].upcase + segment[1..-1]}.join('')
      end

      def constantize(string)
        instance_eval(string)
      end

    end # class << self
  end
end # AASM
