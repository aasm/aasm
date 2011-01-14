module AASM::I18n
  module InstanceMethods
    def human_state
      _translate("attributes", aasm_current_state)
    end
    
    def human_event_name(event)
      _translate("events", event)
    end
    
    private
    
    def _translate(local_scope, attribute)
      lookuped_ancestors = self.class.ancestors.select do |x|
        x.respond_to?(:model_name) unless x == ActiveRecord::Base
      end
      defaults = lookuped_ancestors.map do |klass|
        klass_human = klass.model_name.respond_to?(:i18n_key) ? klass.model_name.i18n_key : klass.name.underscore
        :"#{self.class.i18n_scope}.#{local_scope}.#{klass_human}.state_enum.#{attribute}"
      end
      defaults << attribute.to_s.humanize

      I18n.translate(defaults.shift, :default => defaults, :raise => true)
    end
  end
end
