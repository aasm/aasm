# frozen_string_literal: true

module AASM
  module Core
    module Invokers
      ##
      # Class invoker which allows to use classes which respond to #call
      # to be used as state/event/transition callbacks.
      class ClassInvoker < BaseInvoker
        def may_invoke?
          subject.is_a?(Class) && subject.instance_methods.include?(:call)
        end

        def log_failure
          return log_source_location if Method.method_defined?(:source_location)
          log_method_info
        end

        def invoke_subject
          @result = retrieve_instance.call
        end

        private

        def log_source_location
          failures << instance.method(:call).source_location.join('#')
        end

        def log_method_info
          failures << instance.method(:call)
        end

        def instance
          @instance ||= retrieve_instance
        end

        # rubocop:disable Metrics/AbcSize
        def retrieve_instance
          return subject.new if subject_arity.zero?
          return subject.new(record) if subject_arity == 1
          return subject.new(record, *args) if subject_arity < 0
          subject.new(record, *args[0..(subject_arity - 2)])
        end
        # rubocop:enable Metrics/AbcSize

        def subject_arity
          @arity ||= subject.instance_method(:initialize).arity
        end
      end
    end
  end
end
