require 'spec_helper'

describe "multiple transitions that differ only by guard" do
  let(:job) { MultipleTransitionsThatDifferOnlyByGuard.new }

  it 'does not follow the first transition if its guard fails' do
    expect{job.go}.not_to raise_error
  end

  it 'executes the second transition\'s callbacks' do
    job.go
    expect(job.executed_second).to be_truthy
  end
end
