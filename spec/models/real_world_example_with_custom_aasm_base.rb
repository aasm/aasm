class RealWorldExampleWithCustomAasmBase
  include AASM

  class RequiredParamsEvent < AASM::Core::Event
    def required_params!(*keys)
      options[:before] ||= []
      options[:before] << ->(**args) do
        missing = keys - args.keys
        raise ArgumentError, "Missing required arguments #{missing.inspect}" unless missing == []
      end
    end
  end
  class RequiredParams < AASM::Base
    def aasm_event_class; RequiredParamsEvent; end
  end

  aasm with_klass: RequiredParams do
    state :initialised, :initial => true
    state :filled_out

    event :fill_out do
      required_params! :user, :quantity, :date
      transitions :from => :initialised, :to => :filled_out
    end
  end
end
