module AASM
  module SupportingClasses
    class Localizer
      def human_event_name(klass, event)
        checklist = ancestors_list(klass).inject([]) do |list, ancestor|
          list << :"#{i18n_scope(klass)}.events.#{i18n_klass(ancestor)}.#{event}"
          list
        end
        translate_queue(checklist) || I18n.translate(checklist.shift, :default => event.to_s.humanize)
      end

      def human_state(obj)
        klass = obj.class
        checklist = ancestors_list(klass).inject([]) do |list, ancestor|
          list << item_for(obj, klass, ancestor)
          list << item_for(obj, klass, ancestor, :old_style => true)
          list
        end
        translate_queue(checklist) || I18n.translate(checklist.shift, :default => obj.aasm_current_state.to_s.humanize)
      end

    private

      def item_for(obj, klass, ancestor, options={})
        separator = options[:old_style] ? '.' : '/'
        :"#{i18n_scope(klass)}.attributes.#{i18n_klass(ancestor)}.#{klass.aasm_column}#{separator}#{obj.aasm_current_state}"
      end

      def translate_queue(checklist)
        (0...(checklist.size-1)).each do |i|
          begin
            return I18n.translate(checklist.shift, :raise => true)
          rescue I18n::MissingTranslationData
            # that's okay
          end
        end
        nil
      end

      # added for rails 2.x compatibility
      def i18n_scope(klass)
        klass.respond_to?(:i18n_scope) ? klass.i18n_scope : :activerecord
      end

      # added for rails < 3.0.3 compatibility
      def i18n_klass(klass)
        klass.model_name.respond_to?(:i18n_key) ? klass.model_name.i18n_key : klass.name.underscore
      end

      def ancestors_list(klass)
        klass.ancestors.select do |ancestor|
          ancestor.respond_to?(:model_name) unless ancestor == ActiveRecord::Base
        end
      end
    end
  end # SupportingClasses
end # AASM
