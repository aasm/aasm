require 'spec_helper'

describe AASM::InvalidTransition do
  it 'should not be lazy detecting originating state' do
    process = ProcessWithNewDsl.new
    expect { process.stop! }.to raise_error do |err|
      process.start
      expect(err.message).to eql("Event 'stop' cannot transition from 'sleeping'.")
    end
  end
end
