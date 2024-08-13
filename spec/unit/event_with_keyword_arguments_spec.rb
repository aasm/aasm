require 'spec_helper'

describe EventWithKeywordArguments do
  let(:example) { EventWithKeywordArguments.new }
  describe 'enable keyword arguments' do
    it 'should be executed correctly that method registered by "before hooks" for events with keyword arguments.' do
      expect(example.close(key: 1)).to be_truthy
    end
  end
end
