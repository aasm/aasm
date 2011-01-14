module AASM::I18n
  module InstanceMethods
    def human_state
      ancestors = self.class.ancestors.select do |x|
        x.respond_to?(:model_name) unless x == ActiveRecord::Base
      end
      
      defaults = ancestors.map do |klass|
        human_klass = klass.model_name.respond_to?(:i18n_key) ? klass.model_name.i18n_key : klass.name.underscore
        :"#{self.class.i18n_scope}.attributes.#{human_klass}.#{self.class.aasm_column}.#{aasm_current_state}"
      end
      defaults << aasm_current_state.to_s.humanize

      I18n.translate(defaults.shift, :default => defaults, :raise => true)
    end
    
    def human_event_name(event)
      ancestors = self.class.ancestors.select do |x|
        x.respond_to?(:model_name) unless x == ActiveRecord::Base
      end

      defaults = ancestors.map do |klass|
        human_klass = klass.model_name.respond_to?(:i18n_key) ? klass.model_name.i18n_key : klass.name.underscore
        :"#{self.class.i18n_scope}.events.#{human_klass}.#{event}"
      end
      defaults << event.to_s.humanize

      I18n.translate(defaults.shift, :default => defaults, :raise => true)
    end
  end
end
