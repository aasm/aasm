# frozen_string_literal: true

module AASM
  module Core
    module Invokers
      class ProcInvoker < BaseInvoker
        def may_invoke?
          subject.is_a?(Proc)
        end

        def log_failure
          return log_source_location if Method.method_defined?(:source_location)
          log_proc_info
        end

        def invoke_subject
          @result = if support_parameters?
                      exec_proc(parameters_to_arity)
                    else
                      exec_proc(subject.arity)
                    end
        end

        private

        def support_parameters?
          subject.respond_to?(:parameters)
        end

        def exec_proc(parameters_size)
          return record.instance_exec(&subject) if parameters_size.zero?
          return record.instance_exec(*args, &subject) if parameters_size < 0
          record.instance_exec(*args[0..(parameters_size - 1)], &subject)
        end

        def log_source_location
          failures << subject.source_location.join('#')
        end

        def log_proc_info
          failures << subject
        end

        def parameters_to_arity
          subject.parameters.inject(0) do |memo, parameter|
            memo += 1
            memo *= -1 if parameter[0] == :rest && memo > 0
            memo
          end
        end
      end
    end
  end
end
