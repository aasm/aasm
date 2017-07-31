require 'spec_helper'

describe StatesOnOneLineExample do
  let(:example) { StatesOnOneLineExample.new }
  describe 'on initialize' do
    it 'should be in the initial state' do
      expect(example.aasm(:one_line).current_state).to eql :initial
    end
  end

  describe 'states' do
    it 'should have all 3 states defined' do
      expect(example.aasm(:one_line).states.map(&:name)).to eq [:initial, :first, :second]
    end
  end
end
