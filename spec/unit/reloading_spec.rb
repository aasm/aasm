require 'spec_helper'

describe 'when redefining states' do
  let(:definer) { DoubleDefiner.new }

  it "allows extending states" do
    expect(definer).to receive(:do_enter)
    definer.finish
  end

  it "allows extending events" do
    expect(definer).to receive(:do_on_transition)
    definer.finish
  end
end
