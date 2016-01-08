require 'spec_helper'

describe 'Custom AASM::Base' do
  context 'when aasm_with invoked with SimpleCustomExample' do
    let(:simple_custom) { SimpleCustomExample.new }

    subject do
      simple_custom.fill_out!
      simple_custom.authorise
    end

    it 'has invoked authorizable?' do
      expect { subject }.to change { simple_custom.authorizable_called }.from(nil).to(true)
    end

    it 'has invoked fillable?' do
      expect { subject }.to change { simple_custom.fillable_called }.from(nil).to(true)
    end

    it 'has two transition counts' do
      expect { subject }.to change { simple_custom.transition_count }.from(nil).to(2)
    end
  end

  context 'when aasm_with invoked with non AASM::Base' do
    subject do
      Class.new do
        include AASM

        aasm :with_klass => String do
        end
      end
    end

    it 'should raise an ArgumentError' do
      expect { subject }.to raise_error(ArgumentError, 'The class String must inherit from AASM::Base!')
    end
  end
end
