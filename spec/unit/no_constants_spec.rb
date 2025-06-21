# frozen_string_literal: true

require 'spec_helper'

describe 'No Constants' do
  let(:simple) { NoConstant.new }

  it 'defines constants for each state name' do
    expect(NoConstant.const_defined?('STATE_INITIALISED')).to be_falsey
    expect(NoConstant.const_defined?('STATE_FILLED_OUT')).to be_falsey
    expect(NoConstant.const_defined?('STATE_AUTHORISED')).to be_falsey
  end
end
