require 'spec_helper'

describe AASM::Core::Invoker do
  let(:target) { nil }
  let(:record) { double }
  let(:args) { [] }

  subject { described_class.new(target, record, args) }

  describe '#with_options' do
    context 'when passing array as a subject' do
      context 'and "guard" option is set to true' do
        let(:target) { [subject_1, subject_2] }

        before { subject.with_options(guard: true) }

        context 'and all the subjects are truthy' do
          let(:subject_1) { Proc.new { true } }
          let(:subject_2) { Proc.new { true } }

          it 'then returns "true" while invoking' do
            expect(subject.invoke).to eq(true)
          end
        end

        context 'and any subject is falsely' do
          let(:subject_1) { Proc.new { false } }
          let(:subject_2) { Proc.new { true } }

          it 'then returns "false" while invoking' do
            expect(subject.invoke).to eq(false)
          end
        end
      end

      context 'and "unless" option is set to true' do
        let(:target) { [subject_1, subject_2] }

        before { subject.with_options(unless: true) }

        context 'and all the subjects are falsely' do
          let(:subject_1) { Proc.new { false } }
          let(:subject_2) { Proc.new { false } }

          it 'then returns "true" while invoking' do
            expect(subject.invoke).to eq(true)
          end
        end

        context 'and any subject is truthy' do
          let(:subject_1) { Proc.new { false } }
          let(:subject_2) { Proc.new { true } }

          it 'then returns "false" while invoking' do
            expect(subject.invoke).to eq(false)
          end
        end
      end
    end
  end

  describe '#with_failures' do
    let(:concrete_invoker) { AASM::Core::Invokers::ProcInvoker }
    let(:target) { Proc.new {} }

    it 'then sets failures buffer for concrete invokers' do
      expect_any_instance_of(concrete_invoker)
        .to receive(:with_failures)
        .and_call_original

      subject.invoke
    end
  end

  describe '#with_default_return_value' do
    context 'when return value is "true"' do
      before { subject.with_default_return_value(true) }

      it 'then returns "true" when was not picked up by any invoker' do
        expect(subject.invoke).to eq(true)
      end
    end

    context 'when return value is "false"' do
      before { subject.with_default_return_value(false) }

      it 'then returns "false" when was not picked up by any invoker' do
        expect(subject.invoke).to eq(false)
      end
    end
  end

  describe '#invoke' do
    context 'when subject is a proc' do
      let(:concrete_invoker) { AASM::Core::Invokers::ProcInvoker }
      let(:target) { Proc.new {} }

      it 'then calls proc invoker' do
        expect_any_instance_of(concrete_invoker)
          .to receive(:invoke)
          .and_call_original

        expect(record).to receive(:instance_exec)

        subject.invoke
      end
    end

    context 'when subject is a class' do
      let(:concrete_invoker) { AASM::Core::Invokers::ClassInvoker }
      let(:target) { Class.new { def call; end } }

      it 'then calls proc invoker' do
        expect_any_instance_of(concrete_invoker)
          .to receive(:invoke)
          .and_call_original

        expect_any_instance_of(target).to receive(:call)

        subject.invoke
      end
    end

    context 'when subject is a literal' do
      let(:concrete_invoker) { AASM::Core::Invokers::LiteralInvoker }
      let(:record) { double(invoke_me: nil) }
      let(:target) { :invoke_me }

      it 'then calls literal invoker' do
        expect_any_instance_of(concrete_invoker)
          .to receive(:invoke)
          .and_call_original

        expect(record).to receive(:invoke_me)

        subject.invoke
      end
    end

    context 'when subject is an array of procs' do
      let(:subject_1) { Proc.new {} }
      let(:subject_2) { Proc.new {} }
      let(:target) { [subject_1, subject_2] }

      it 'then calls each proc' do
        expect(record).to receive(:instance_exec).twice

        subject.invoke
      end
    end

    context 'when subject is an array of classes' do
      let(:subject_1) { Class.new { def call; end } }
      let(:subject_2) { Class.new { def call; end } }
      let(:target) { [subject_1, subject_2] }

      it 'then calls each class' do
        expect_any_instance_of(subject_1).to receive(:call)

        expect_any_instance_of(subject_2).to receive(:call)

        subject.invoke
      end
    end

    context 'when subject is an array of literals' do
      let(:subject_1) { :method_one }
      let(:subject_2) { :method_two }
      let(:record) { double(method_one: nil, method_two: nil) }
      let(:target) { [subject_1, subject_2] }

      it 'then calls each class' do
        expect(record).to receive(:method_one)

        expect(record).to receive(:method_two)

        subject.invoke
      end
    end

    context 'when subject is not supported' do
      let(:target) { nil }

      it 'then just returns default value' do
        expect(subject.invoke).to eq(described_class::DEFAULT_RETURN_VALUE)
      end
    end
  end
end
