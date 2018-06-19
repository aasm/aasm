require 'spec_helper'

describe AASM::Core::Invokers::BaseInvoker do
  let(:target) { double }
  let(:record) { double }
  let(:args) { [] }

  subject { described_class.new(target, record, args) }

  describe '#may_invoke?' do
    it 'then raises NoMethodError' do
      expect { subject.may_invoke? }.to raise_error(NoMethodError)
    end
  end

  describe '#log_failure' do
    it 'then raises NoMethodError' do
      expect { subject.log_failure }.to raise_error(NoMethodError)
    end
  end

  describe '#invoke_subject' do
    it 'then raises NoMethodError' do
      expect { subject.log_failure }.to raise_error(NoMethodError)
    end
  end

  describe '#with_failures' do
    it 'then sets failures buffer' do
      buffer = [1, 2, 3]
      subject.with_failures(buffer)

      expect(subject.failures).to eq(buffer)
    end
  end

  describe '#invoke' do
    context 'when #may_invoke? respond with "false"' do
      before { allow(subject).to receive(:may_invoke?).and_return(false) }

      it 'then returns "nil"' do
        expect(subject.invoke).to eq(nil)
      end
    end

    context 'when #invoke_subject respond with "false"' do
      before do
        allow(subject).to receive(:may_invoke?).and_return(true)
        allow(subject).to receive(:invoke_subject).and_return(false)
      end

      it 'then calls #log_failure' do
        expect(subject).to receive(:log_failure)

        subject.invoke
      end
    end

    context 'when #invoke_subject succeed' do
      before do
        allow(subject).to receive(:may_invoke?).and_return(true)
        allow(subject).to receive(:invoke_subject).and_return(true)
      end

      it 'then returns result' do
        expect(subject).to receive(:result)

        subject.invoke
      end
    end
  end
end
