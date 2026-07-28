require 'spec_helper'

describe "real world example suing ASM::Base and custom core classes" do

  let(:example) {RealWorldExampleWithCustomAasmBase.new}

  it 'should succeed with the correct parameters' do
    expect { example.fill_out(:user => 1, :quantity => 3, :date => Date.today) }.not_to raise_exception
  end

  it 'should raise an exception if the correct parameters are not given' do
    expect { example.fill_out(:user => 1) }.to raise_exception(ArgumentError, 'Missing required arguments [:quantity, :date]')
  end
end
