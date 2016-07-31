require 'spec_helper'

describe "guards with params" do
  let(:guard) { GuardWithParamsMultiple.new }
  let(:user) {GuardParamsClass.new}

  it "list permitted states" do
    expect(guard.aasm(:left).states({:permitted => true}, user).map(&:name)).to eql [:reviewed]
  end
end
