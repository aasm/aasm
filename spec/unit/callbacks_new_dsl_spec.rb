require 'spec_helper'

describe 'callbacks for the new DSL' do
  before(:each) do
    @callback = CallbackNewDsl.new
  end

  it "should get close callbacks" do
    @callback.should_receive(:before).once.ordered
    @callback.should_receive(:before_exit_open).once.ordered                   # these should be before the state changes
    @callback.should_receive(:before_enter_closed).once.ordered
    @callback.should_receive(:aasm_write_state).once.ordered.and_return(true)  # this is when the state changes
    @callback.should_receive(:after_exit_open).once.ordered                    # these should be after the state changes
    @callback.should_receive(:after_enter_closed).once.ordered
    @callback.should_receive(:after).once.ordered

    @callback.close!
  end

  it "should get open callbacks" do
    @callback.close!

    @callback.should_receive(:before).once.ordered
    @callback.should_receive(:before_exit_closed).once.ordered                # these should be before the state changes
    @callback.should_receive(:before_enter_open).once.ordered
    @callback.should_receive(:aasm_write_state).once.ordered.and_return(true) # this is when the state changes
    @callback.should_receive(:after_exit_closed).once.ordered                 # these should be after the state changes
    @callback.should_receive(:after_enter_open).once.ordered
    @callback.should_receive(:after).once.ordered

    @callback.open!
  end
end
