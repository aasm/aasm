require 'spec_helper'

describe EventWithKeywordArguments do
  let(:example) { EventWithKeywordArguments.new }
  describe 'enable keyword arguments' do
    it 'should be executed correctly that method registered by "before hooks" for events with keyword arguments.' do
      expect(example).to receive(:_before_close).with(key: 1)
      expect(example.close(key: 1)).to be_truthy
    end

    it 'should be executed correctly that method registered by "before hooks" for events with keyword arguments.' do
      expect(example).to receive(:_before_close).with(key: nil)
      expect(example.close(key: nil)).to be_truthy
    end

    it 'should be executed correctly that method registered by "before hooks" for events with positional and keyword arguments.' do
      expect(example).to receive(:_before_another_close).with(1, key: 2)
      expect(example.another_close(1, key: 2)).to be_truthy
    end

    it 'should be executed correctly that method registered by "before hooks" for events with positional and keyword arguments.' do
      expect(example).to receive(:_before_another_close).with(1, key: nil, a: 1)
      expect(example.another_close(1, key: nil, a: 1)).to be_truthy
    end
  end
end
