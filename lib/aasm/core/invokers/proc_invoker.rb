# frozen_string_literal: true

module AASM
  module Core
    module Invokers
      ##
      # Proc invoker which allows to use Procs as
      # state/event/transition callbacks.
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

        def keyword_arguments?
          return false unless support_parameters?
          subject.parameters.any? { |type, _| [:key, :keyreq].include?(type) }
        end

        def exec_proc_with_keyword_args(parameters_size)
          positional_args, keyword_args = parse_arguments

          if keyword_args.nil?
            if parameters_size < 0
              record.instance_exec(*positional_args, &subject)
            else
              record.instance_exec(*positional_args[0..(parameters_size - 1)], &subject)
            end
          else
            if parameters_size < 0
              record.instance_exec(*positional_args, **keyword_args, &subject)
            else
              record.instance_exec(*positional_args[0..(parameters_size - 1)], **keyword_args, &subject)
            end
          end
        end

        # rubocop:disable Metrics/AbcSize
        def exec_proc(parameters_size)
          return record.instance_exec(&subject) if parameters_size.zero? && !keyword_arguments?
          
          if keyword_arguments?
            exec_proc_with_keyword_args(parameters_size)
          elsif parameters_size < 0
            record.instance_exec(*args, &subject)
          else
            record.instance_exec(*args[0..(parameters_size - 1)], &subject)
          end
        end
        # rubocop:enable Metrics/AbcSize

        def log_source_location
          failures << subject.source_location.join('#')
        end

        def log_proc_info
          failures << subject
        end

        def parameters_to_arity
          subject.parameters.inject(0) do |memo, parameter|
            case parameter[0]
            when :key, :keyreq
              # Keyword arguments don't count towards positional arity
            when :rest
              memo = memo > 0 ? -memo : -1
            else
              memo += 1
            end
            memo
          end
        end
      end
    end
  end
end
