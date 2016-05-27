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
    class Base
      def valid?; end
    end
    it do
      expect { Base.send :include, Clumsy }.
        to output(/Base: overriding method 'valid\?'!/).to_stderr
    end
  end

  describe 'enum' do
    class EnumBase
      def valid?; end
    end
    it "dosn't warn when overriding an enum" do
      expect { EnumBase.send :include, WithEnumBase }.
        not_to output(/EnumBase: overriding method 'valid\?'!/).to_stderr
    end
  end

  describe 'event' do
    context 'may?' do
      class Base
        def may_save?; end
        def save!; end
        def save; end
      end
      let(:klass) { Base }
      it do
        expect { Base.send :include, Clumsy }.
          to output(/Base: overriding method 'may_save\?'!/).to_stderr
        expect { Base.send :include, Clumsy }.
          to output(/Base: overriding method 'save!'!/).to_stderr
        expect { Base.send :include, Clumsy }.
          to output(/Base: overriding method 'save'!/).to_stderr
      end
    end
  end

end
