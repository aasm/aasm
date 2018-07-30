require 'spec_helper'

describe AASM::Core::Invokers::ProcInvoker do
  let(:target) { Proc.new {} }
  let(:record) { double }
  let(:args) { [] }

  subject { described_class.new(target, record, args) }

  describe '#may_invoke?' do
    context 'when subject is a Proc' do
      it 'then returns "true"' do
        expect(subject.may_invoke?).to eq(true)
      end
    end

    context 'when subject is not a Proc' do
      let(:target) { nil }

      it 'then returns "false"' do
        expect(subject.may_invoke?).to eq(false)
      end
    end
  end

  describe '#log_failure' do
    context 'when subject respond to #source_location' do
      it 'then adds "source_location" to a failures buffer' do
        subject.log_failure

        expect(subject.failures)
          .to eq([target.source_location.join('#')])
      end
    end

    context 'when subject does not respond to #source_location' do
      before do
        Method.__send__(:alias_method, :original_source_location, :source_location)
        Method.__send__(:undef_method, :source_location)
      end

      after do
        Method.__send__(
          :define_method,
          :source_location,
          Method.instance_method(:original_source_location)
        )
      end

      it 'then adds the subject to a failures buffer' do
        subject.log_failure

        expect(subject.failures).to eq([target])
      end
    end
  end

  describe '#invoke_subject' do
    context 'when passing no arguments' do
      let(:args) { [1, 2 ,3] }
      let(:target) { ->() {} }

      it 'then correctly uses passed arguments' do
        expect { subject.invoke_subject }.not_to raise_error
      end
    end

    context 'when passing variable number arguments' do
      let(:args) { [1, 2 ,3, 4, 5, 6] }
      let(:target) { ->(_a, _b, *_c) {} }

      it 'then correctly uses passed arguments' do
        expect { subject.invoke_subject }.not_to raise_error
      end
    end

    context 'when passing one or more arguments' do
      let(:args) { [1, 2 ,3, 4, 5, 6] }
      let(:target) { ->(_a, _b, _c) {} }

      it 'then correctly uses passed arguments' do
        expect { subject.invoke_subject }.not_to raise_error
      end
    end
  end
end
