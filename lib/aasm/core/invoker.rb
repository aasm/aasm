# frozen_string_literal: true

module AASM
  module Core
    ##
    # main invoker class which encapsulates the logic
    # for invoking literal-based, proc-based, class-based
    # and array-based callbacks for different entities.
    class Invoker
      DEFAULT_RETURN_VALUE = true

      ##
      # Initialize a new invoker instance.
      # NOTE that invoker must be used per-subject/record
      #      (one instance per subject/record)
      #
      # ==Options:
      #
      # +subject+ - invoking subject, may be Proc,
      #             Class, String, Symbol or Array
      # +record+  - invoking record
      # +args+    - arguments which will be passed to the callback

      def initialize(subject, record, args)
        @subject = subject
        @record = record
        @args = args
        @options = {}
        @failures = []
        @default_return_value = DEFAULT_RETURN_VALUE
      end

      ##
      # Pass additional options to concrete invoker
      #
      # ==Options:
      #
      # +options+ - hash of options which will be passed to
      #             concrete invokers
      #
      # ==Example:
      #
      # with_options(guard: proc {...})

      def with_options(options)
        @options = options
        self
      end

      ##
      # Collect failures to a specified buffer
      #
      # ==Options:
      #
      # +failures+ - failures buffer to collect failures

      def with_failures(failures)
        @failures = failures
        self
      end

      ##
      # Change default return value of #invoke method
      # if none of invokers processed the request.
      #
      # The default return value is #DEFAULT_RETURN_VALUE
      #
      # ==Options:
      #
      # +value+ - default return value for #invoke method

      def with_default_return_value(value)
        @default_return_value = value
        self
      end

      ##
      # Find concrete invoker for specified subject and invoker it,
      # or return default value set by #DEFAULT_RETURN_VALUE or
      # overridden by #with_default_return_value

      # rubocop:disable Metrics/AbcSize
      def invoke
        return invoke_array if subject.is_a?(Array)
        return literal_invoker.invoke if literal_invoker.may_invoke?
        return proc_invoker.invoke if proc_invoker.may_invoke?
        return class_invoker.invoke if class_invoker.may_invoke?
        default_return_value
      end
      # rubocop:enable Metrics/AbcSize

      private

      attr_reader :subject, :record, :args, :options, :failures,
                  :default_return_value

      def invoke_array
        return subject.all? { |item| sub_invoke(item) } if options[:guard]
        return subject.all? { |item| !sub_invoke(item) } if options[:unless]
        subject.map { |item| sub_invoke(item) }
      end

      def sub_invoke(new_subject)
        self.class.new(new_subject, record, args)
            .with_failures(failures)
            .with_options(options)
            .invoke
      end

      def proc_invoker
        @proc_invoker ||= Invokers::ProcInvoker
                          .new(subject, record, args)
                          .with_failures(failures)
      end

      def class_invoker
        @class_invoker ||= Invokers::ClassInvoker
                           .new(subject, record, args)
                           .with_failures(failures)
      end

      def literal_invoker
        @literal_invoker ||= Invokers::LiteralInvoker
                             .new(subject, record, args)
                             .with_failures(failures)
      end
    end
  end
end
