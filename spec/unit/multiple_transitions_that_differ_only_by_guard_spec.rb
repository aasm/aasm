require 'spec_helper'

describe "multiple transitions that differ only by guard" do
  let(:job) { MultipleTransitionsThatDifferOnlyByGuard.new }

  it 'does not follow the first transition if its guard fails' do
    expect{job.go}.not_to raise_error
  end
end
