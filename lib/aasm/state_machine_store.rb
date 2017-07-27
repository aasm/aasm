require 'concurrent'
module AASM
  class StateMachineStore
    @stores = Concurrent::Map.new

    class << self
      def stores
        @stores
      end

      # do not overwrite existing state machines, which could have been created by
      # inheritance, see AASM::ClassMethods method inherited
      def register(klass, overwrite = false, state_machine = nil)
        raise "Cannot register #{klass}" unless klass.is_a?(Class)

        case name = template = overwrite
          when FalseClass then stores[klass.to_s] ||= new
          when TrueClass then stores[klass.to_s] = new
          when Class then stores[klass.to_s] = stores[template.to_s].clone
          when Symbol then stores[klass.to_s].register(name, state_machine)
          when String then stores[klass.to_s].register(name, state_machine)
          else raise "Don't know what to do with #{overwrite}"
        end
      end
      alias_method :[]=, :register

      def fetch(klass, fallback = nil)
        stores[klass.to_s] || fallback && begin
          match = klass.ancestors.find do |ancestor|
            ancestor.include? AASM and stores[ancestor.to_s]
          end

          stores[match.to_s]
        end
      end
      alias_method :[], :fetch

      def unregister(klass)
        stores.delete(klass.to_s)
      end
    end

    def initialize
      @machines = Concurrent::Map.new
    end

    def clone
      StateMachineStore.new.tap do |store|
        @machines.each_pair do |name, machine|
          store.register(name, machine.clone)
        end
      end
    end

    def machine(name)
      @machines[name.to_s]
    end
    alias_method :[], :machine

    def machine_names
      @machines.keys
    end
    alias_method :keys, :machine_names

    def register(name, machine, force = false)
      raise "Cannot use #{name.inspect} for machine name" unless name.is_a?(Symbol) or name.is_a?(String)
      raise "Cannot use #{machine.inspect} as a machine" unless machine.is_a?(AASM::StateMachine)

      if force
        @machines[name.to_s] = machine
      else
        @machines[name.to_s] ||= machine
      end
    end
  end
end
