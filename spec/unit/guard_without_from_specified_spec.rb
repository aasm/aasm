require 'spec_helper'

describe "transitions without from specified" do
  let(:guardian) { GuardianWithoutFromSpecified.new }

  it "allows the transitions if guard succeeds" do
    expect { guardian.use_guards_where_the_first_fails! }.to_not raise_error
    expect(guardian).to be_gamma
  end
end
