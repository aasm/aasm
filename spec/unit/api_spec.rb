require 'spec_helper'
require 'models/active_record/api.rb'

describe "retrieving the current state" do
  it "uses the AASM default" do
    DefaultState.new.aasm.current_state.should eql :alpha
  end

  it "uses the provided method" do
    ProvidedState.new.aasm.current_state.should eql :beta
  end

  it "uses the persistence storage" do
    PersistedState.new.aasm.current_state.should eql :alpha
  end

  it "uses the provided method even if persisted" do
    ProvidedAndPersistedState.new.aasm.current_state.should eql :gamma
  end
end
