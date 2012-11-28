require 'spec_helper'

describe "the new dsl" do

  let(:process) {ProcessWithNewDsl.new}

  it 'should use an initial event' do
    process.aasm_current_state.should == :sleeping
    process.should be_sleeping
  end

  it 'should have states and transitions' do
    process.flagged.should be_nil
    process.start!
    process.should be_running
    process.flagged.should be_true
    process.stop!
    process.should be_suspended
  end

  it 'should not conflict with other event or state methods' do
    lambda {ProcessWithNewDsl.state}.should raise_error(RuntimeError, "wrong state method")
    lambda {ProcessWithNewDsl.event}.should raise_error(RuntimeError, "wrong event method")
  end

end
