# frozen_string_literal: true

module AASM
  module Core
    module Invokers
      ##
      # Base concrete invoker class which contain basic
      # invoking and logging definitions
      class BaseInvoker
        attr_reader :failures, :subject, :record, :args, :result

        ##
        # Initialize a new concrete invoker instance.
        # NOTE that concrete invoker must be used per-subject/record
        #      (one instance per subject/record)
        #
        # ==Options:
        #
        # +subject+ - invoking subject comparable with this invoker
        # +record+  - invoking record
        # +args+    - arguments which will be passed to the callback

        def initialize(subject, record, args)
          @subject = subject
          @record = record
          @args = args
          @result = false
          @failures = []
        end

        ##
        # Collect failures to a specified buffer
        #
        # ==Options:
        #
        # +failures+ - failures buffer to collect failures

        def with_failures(failures_buffer)
          @failures = failures_buffer
          self
        end

        ##
        # Execute concrete invoker, log the error and return result

        def invoke
          return unless may_invoke?
          log_failure unless invoke_subject
          result
        end

        ##
        # Check if concrete invoker may be invoked for a specified subject

        def may_invoke?
          raise NoMethodError, '"#may_invoke?" is not implemented'
        end

        ##
        # Log failed invoking

        def log_failure
          raise NoMethodError, '"#log_failure" is not implemented'
        end

        ##
        # Execute concrete invoker

        def invoke_subject
          raise NoMethodError, '"#invoke_subject" is not implemented'
        end
      end
    end
  end
end
