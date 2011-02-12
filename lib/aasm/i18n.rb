class AASM::I18n
  def human_event_name(klass, event)
    defaults = ancestors_list(klass).map do |ancestor|
      :"#{klass.i18n_scope}.events.#{i18n_klass(ancestor)}.#{event}"
    end << event.to_s.humanize
  
    I18n.translate(defaults.shift, :default => defaults, :raise => true)
  end

  def human_state(obj)
    klass = obj.class
    defaults = ancestors_list(klass).map do |ancestor|
      :"#{klass.i18n_scope}.attributes.#{i18n_klass(ancestor)}.#{klass.aasm_column}.#{obj.aasm_current_state}"
    end << obj.aasm_current_state.to_s.humanize

    I18n.translate(defaults.shift, :default => defaults, :raise => true)
  end

  private

  def i18n_klass(klass)
    klass.model_name.respond_to?(:i18n_key) ? klass.model_name.i18n_key : klass.name.underscore
  end

  def ancestors_list(klass)
    klass.ancestors.select do |ancestor|
      ancestor.respond_to?(:model_name) unless ancestor == ActiveRecord::Base
    end
  end
end
