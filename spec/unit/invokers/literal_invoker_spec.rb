require 'spec_helper'

describe AASM::Core::Invokers::LiteralInvoker do
  let(:target) { nil }
  let(:record) { double }
  let(:args) { [] }

  subject { described_class.new(target, record, args) }

  describe '#may_invoke?' do
    context 'when subject is a Symbol' do
      let(:target) { :i_am_symbol }

      it 'then returns "true"' do
        expect(subject.may_invoke?).to eq(true)
      end
    end

    context 'when subject is a String' do
      let(:target) { 'i_am_string' }

      it 'then returns "true"' do
        expect(subject.may_invoke?).to eq(true)
      end
    end

    context 'when subject is neither a String nor Symbol' do
      let(:target) { double }

      it 'then returns "false"' do
        expect(subject.may_invoke?).to eq(false)
      end
    end
  end

  describe '#log_failure' do
    let(:target) { Proc.new { false } }

    it 'then adds the subject to a failures buffer' do
      subject.log_failure

      expect(subject.failures).to eq([target])
    end
  end

  describe '#invoke_subject' do
    context 'when passing no arguments' do
      let(:record) { Class.new { def my_method; end }.new }
      let(:args) { [1, 2 ,3] }
      let(:target) { :my_method }

      it 'then correctly uses passed arguments' do
        expect { subject.invoke_subject }.not_to raise_error
      end
    end

    context 'when passing variable number arguments' do
      let(:record) { Class.new { def my_method(_a, _b, *_c); end }.new }
      let(:args) { [1, 2 ,3, 4, 5, 6] }
      let(:target) { :my_method }

      it 'then correctly uses passed arguments' do
        expect { subject.invoke_subject }.not_to raise_error
      end
    end

    context 'when passing one or more arguments' do
      let(:record) { Class.new { def my_method(_a, _b, _c); end }.new }
      let(:args) { [1, 2 ,3, 4, 5, 6] }
      let(:target) { :my_method }

      it 'then correctly uses passed arguments' do
        expect { subject.invoke_subject }.not_to raise_error
      end
    end

    context 'when record does not respond to subject' do
      let(:record) { Class.new { }.new }
      let(:target) { :my_method }

      it 'then raises uses passed arguments' do
        expect { subject.invoke_subject }.to raise_error(NoMethodError)
      end
    end
  end
end
