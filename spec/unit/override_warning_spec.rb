require 'spec_helper'

describe 'warns when overrides a method' do
  module Clumsy
    def self.included base
      base.send :include, AASM

      base.aasm do
        state :valid
        event(:save) { }
      end
    end
  end

  module SlightlyAcknowledgedClumsy
    def self.included base
      base.send :include, AASM

      base.aasm(:override_methods => [:valid?]) do
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
    let(:error_message) { %r{overriding method 'valid\?'!} }
    let(:clumsy_base) do
      Class.new do
        def valid?; end
      end
    end

    context 'with Clumsy' do
      it do
        expect { clumsy_base.send :include, Clumsy }.
          to output(error_message).to_stderr
      end
    end

    context 'with SlightlyAcknowledgedClumsy' do
      it do
        expect { clumsy_base.send :include, SlightlyAcknowledgedClumsy }.
          to_not output(error_message).to_stderr
      end
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

      context 'with Clumsy' do
        it do
          expect { base_klass.send :include, Clumsy }.
            to output(error_override_may_save?).to_stderr
          expect { base_klass.send :include, Clumsy }.
            to output(error_override_save!).to_stderr
          expect { base_klass.send :include, Clumsy }.
            to output(error_override_save).to_stderr
        end
      end

      context 'with SlightlyAcknowledgedClumsy' do
        it do
          expect { base_klass.send :include, SlightlyAcknowledgedClumsy }.
            to output(error_override_may_save?).to_stderr
          expect { base_klass.send :include, SlightlyAcknowledgedClumsy }.
            to output(error_override_save!).to_stderr
          expect { base_klass.send :include, SlightlyAcknowledgedClumsy }.
            to output(error_override_save).to_stderr
        end
      end
    end
  end
end
