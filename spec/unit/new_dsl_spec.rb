require 'spec_helper'

describe "the new dsl" do

  let(:process) {ProcessWithNewDsl.new}

  it 'should not conflict with other event or state methods' do
    expect {ProcessWithNewDsl.state}.to raise_error(RuntimeError, "wrong state method")
    expect {ProcessWithNewDsl.event}.to raise_error(RuntimeError, "wrong event method")
  end

end
