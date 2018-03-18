# frozen_string_literal: true

module AASM
  module Core
    module Invokers
      ##
      # Literal invoker which allows to use strings or symbols to call
      # record methods as state/event/transition callbacks.
      class LiteralInvoker < BaseInvoker
        def may_invoke?
          subject.is_a?(String) || subject.is_a?(Symbol)
        end

        def log_failure
          failures << subject
        end

        def invoke_subject
          @result = exec_subject
        end

        private

        def subject_arity
          @arity ||= record.__send__(:method, subject.to_sym).arity
        end

        # rubocop:disable Metrics/AbcSize
        def exec_subject
          raise(*record_error) unless record.respond_to?(subject, true)
          return record.__send__(subject) if subject_arity.zero?
          return record.__send__(subject, *args) if subject_arity < 0
          record.__send__(subject, *args[0..(subject_arity - 1)])
        end
        # rubocop:enable Metrics/AbcSize

        def record_error
          [
            NoMethodError,
            'NoMethodError: undefined method ' \
            "`#{subject}' for #{record.inspect}:#{record.class}"
          ]
        end
      end
    end
  end
end
