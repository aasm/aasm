require 'spec_helper'

describe ClassWithKeywordArguments do
  let(:state_machine) { ClassWithKeywordArguments.new }
  let(:resource) { double('resource', value: 1) }

  context 'when using optional keyword arguments' do
    it 'changes state successfully to closed_temporarily' do
      expect(state_machine.close_temporarily!(my_optional_arg: 'closed_temporarily')).to be_truthy
      expect(state_machine.my_attribute).to eq('closed_temporarily')
    end

    it 'changes state successfully to closed_temporarily when optional keyword argument is not provided' do
      expect(state_machine.close_temporarily!()).to be_truthy
      expect(state_machine.my_attribute).to eq('closed_forever')
    end
  end

  it 'changes state successfully to closed_forever' do
    expect(state_machine.close_forever!).to be_truthy
    expect(state_machine.my_attribute).to eq('closed_forever')
  end 

  it 'changes state successfully to closed_then_something_else' do
    expect(state_machine.close_then_something_else!(my_required_arg: 'closed_then_something_else')).to be_truthy
    expect(state_machine.my_attribute).to eq('closed_then_something_else')
  end
end
