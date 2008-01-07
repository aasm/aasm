module AASM
  module SupportingClasses
    class StateFactory
      def self.create(name, opts={})
        @states ||= {}
        @states[name] ||= State.new(name, opts)
      end

      def self.[](name)
        @states[name]
      end
    end
  end
end
