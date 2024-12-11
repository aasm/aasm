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

        def exec_subject
          raise(*record_error) unless record.respond_to?(subject, true)
          
          if subject_arity.zero?
            record.__send__(subject)
          elsif subject_arity < 0
            invoke_with_variable_arity
          else
            invoke_with_fixed_arity
          end
        end

        def invoke_with_variable_arity
          if args.last.is_a?(Hash)
            new_args = args[0..-2]
            keyword_args = args.last
            record.__send__(subject, *new_args, **keyword_args)
          else
            record.__send__(subject, *args)
          end
        end

        def invoke_with_fixed_arity
          req_args = args[0..(subject_arity - 1)]
          if req_args[0].is_a?(Hash)
            record.__send__(subject, **req_args[0])
          else
            record.__send__(subject, *req_args)
          end
        end

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
