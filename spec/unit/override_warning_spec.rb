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

  describe 'state' do
    class Base
      def valid?; end
    end
    it do
      expect { Base.send :include, Clumsy }.
        to output(/Base: overriding method 'valid\?'!/).to_stderr
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
