require 'spec_helper'

describe "guards with params" do
  let(:guard) { GuardWithParams.new }
  let(:user) {GuardParamsClass.new}

  it "list permitted states" do
    expect(guard.aasm.states({:permitted => true}, user).map(&:name)).to eql [:reviewed]
  end
end
