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
          @result = instance.call
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

        def retrieve_instance
          return subject.new if subject_arity.zero?
          return subject.new(record) if subject_arity == 1
          
          if keyword_arguments?
            instance_with_keyword_args
          elsif subject_arity < 0
            subject.new(record, *args)
          else
            instance_with_fixed_arity
          end
        end

        def keyword_arguments?
          params = subject.instance_method(:initialize).parameters
          params.any? { |type, _| [:key, :keyreq].include?(type) }
        end

        def instance_with_keyword_args
          positional_args, keyword_args = parse_arguments

          if keyword_args.nil?
            subject.new(record, *positional_args)
          else
            subject.new(record, *positional_args, **keyword_args)
          end
        end

        def instance_with_fixed_arity
          subject.new(record, *args[0..(subject_arity - 2)])
        end

        def subject_arity
          @arity ||= subject.instance_method(:initialize).arity
        end
      end
    end
  end
end
