require 'spec_helper'

describe EventWithKeywordArguments do
  let(:example) { EventWithKeywordArguments.new }

  context 'when using required keyword arguments' do
    it 'works with required keyword argument' do
      expect(example.close(key: 1)).to be_truthy
    end

    it 'works when required keyword argument is nil' do
      expect(example.close(key: nil)).to be_truthy
    end

    it 'fails when the required keyword argument is not provided' do
      expect { example.close() }.to raise_error(ArgumentError)
    end
  end

  context 'when mixing positional and keyword arguments' do
    it 'works with defined keyword arguments' do
      expect(example.another_close(1, key: 2)).to be_truthy
    end

    it 'works when optional keyword argument is nil' do
      expect(example.another_close(1, key: nil)).to be_truthy
    end

    it 'works when optional keyword argument is not provided' do
      expect(example.another_close(1)).to be_truthy
    end
  end
end
