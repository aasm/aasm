module AASM
  class Transition
    attr_reader :from, :to, :opts
    alias_method :options, :opts

    def initialize(opts)
      @from = opts[:from]
      @to = opts[:to]
      @guards = Array(opts[:guard] || opts[:guards])
      @on_transition = opts[:on_transition]
      @opts = opts
    end

    # TODO: should be named allowed? or similar
    def perform(obj, *args)
      @guards.each do |guard|
        case guard
        when Symbol, String
          return false unless obj.send(guard, *args)
        when Proc
          return false unless guard.call(obj, *args)
        end
      end
      true
    end

    def execute(obj, *args)
      @on_transition.is_a?(Array) ?
              @on_transition.each {|ot| _execute(obj, ot, *args)} :
              _execute(obj, @on_transition, *args)
    end

    def ==(obj)
      @from == obj.from && @to == obj.to
    end

    def from?(value)
      @from == value
    end

    private

    def _execute(obj, on_transition, *args)
      obj.aasm.from_state = @from if obj.aasm.respond_to?(:from_state=)
      obj.aasm.to_state = @to if obj.aasm.respond_to?(:to_state=)

      case on_transition
      when Proc
        on_transition.arity == 0 ? on_transition.call : on_transition.call(obj, *args)
      when Symbol, String
        obj.send(:method, on_transition.to_sym).arity == 0 ? obj.send(on_transition) : obj.send(on_transition, *args)
      end
    end

  end
end # AASM
