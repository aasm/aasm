require 'spec_helper'

describe 'warns when overrides a method' do
  before do
    AASM::Configuration.hide_warnings = false
  end

  after do
    AASM::Configuration.hide_warnings = true
  end

  module Clumsy
    def self.included base
      base.send :include, AASM

      base.aasm do
        state :valid
        event(:save) { }
      end
    end
  end

  module WithEnumBase
    def self.included base
      base.send :include, AASM
      base.instance_eval do
        def defined_enums
          { 'state' => { 'valid' => 0, 'invalid' => 1 } }
        end
      end
      base.aasm enum: true do
        state :valid
        event(:save) { }
      end
    end
  end

  describe 'state' do
    let(:base_klass) do
      Class.new do
        def valid?; end
      end
    end

    subject { base_klass.send :include, Clumsy }

    it 'should log to warn' do
      expect_any_instance_of(Logger).to receive(:warn).with(": overriding method 'valid?'!")
      subject
    end
  end

  describe 'enum' do
    let(:enum_base_klass) do
      Class.new do
        def valid?; end
      end
    end

    subject { enum_base_klass.send :include, WithEnumBase }

    it 'should not log to warn' do
      expect_any_instance_of(Logger).to receive(:warn).never
      subject
    end
  end

  describe 'event' do
    context 'may?' do
      let(:base_klass) do
        Class.new do
          def may_save?; end
          def save!; end
          def save; end
        end
      end

      subject { base_klass.send :include, Clumsy }

      it 'should log to warn' do
        expect_any_instance_of(Logger).to receive(:warn).exactly(3).times do |logger, message|
          expect(
            [
              ": overriding method 'may_save?'!",
              ": overriding method 'save!'!",
              ": overriding method 'save'!"
            ]
          ).to include(message)
        end
        subject
      end
    end
  end
end
