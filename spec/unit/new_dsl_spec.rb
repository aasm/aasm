require 'spec_helper'

describe "the new dsl" do

  let(:process) {ProcessWithNewDsl.new}

  it 'should not conflict with other event or state methods' do
    lambda {ProcessWithNewDsl.state}.should raise_error(RuntimeError, "wrong state method")
    lambda {ProcessWithNewDsl.event}.should raise_error(RuntimeError, "wrong event method")
  end

end
