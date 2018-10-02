Rails.root.glob("app/models/*.rb").each {|path| require path }

FactoryBot.modify do
  AASM::StateMachineStore.stores.each do |model_name, store|
    factory_name = model_name.underscore.to_sym
    next unless FactoryBot.factories.registered?(factory_name)

    factory factory_name do
      store["default"].states.each do |state|
        trait state.name do
          aasm_state { state.name }
        end
      end
    end
  end
end
