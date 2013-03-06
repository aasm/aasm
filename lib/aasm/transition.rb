module AASM
  class Transition
    include DslHelper

    attr_reader :from, :to, :opts
    alias_method :options, :opts

    def initialize(opts, &block)
      # QUESTION: rename :on_transition to :after?
      add_options_from_dsl(opts, [:on_transition, :guard], &block) if block

      @from, @to, @guard, @on_transition = opts[:from], opts[:to], opts[:guard], opts[:on_transition]
      @opts = opts
    end

    # TODO: should be named allowed? or similar
    def perform(obj, *args)
      invoke_callbacks_compatible_with_guard(@guard, obj, args)
    end

    def execute(obj, *args)
      invoke_callbacks_compatible_with_guard(@on_transition, obj, args)
    end

    def ==(obj)
      @from == obj.from && @to == obj.to
    end

    def from?(value)
      @from == value
    end

    private

    def invoke_callbacks_compatible_with_guard(code, record, args)
      case code
        when Symbol, String
          # QUESTION : record.send(code, *args) ?
          arity = record.send(:method, code.to_sym).arity
          arity == 0 ? record.send(code) : record.send(code, *args)
        when Proc
          # QUESTION : record.instance_exec(*args, &code) ?
          code.arity == 0 ? record.instance_exec(&code) : record.instance_exec(*args, &code)
        when Array
          # code.all? {...} fails in on_transition
          code.map {|a| invoke_callbacks_compatible_with_guard(a, record, args)}.all?
        else
          true
      end
    end
  end
end # AASM
