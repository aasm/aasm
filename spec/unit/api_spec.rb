require 'spec_helper'
require 'models/active_record/api.rb'

describe "reading the current state" do
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

describe "writing and persisting the current state" do
  it "uses the AASM default" do
    o = DefaultState.new
    o.release!
    o.persisted_store.should be_nil
  end

  it "uses the provided method" do
    o = ProvidedState.new
    o.release!
    o.persisted_store.should eql :beta
  end

  it "uses the persistence storage" do
    o = PersistedState.new
    o.release!
    o.persisted_store.should be_nil
  end

  it "uses the provided method even if persisted" do
    o = ProvidedAndPersistedState.new
    o.release!
    o.persisted_store.should eql :beta
  end
end

describe "writing the current state without persisting it" do
  it "uses the AASM default" do
    o = DefaultState.new
    o.release
    o.transient_store.should be_nil
  end

  it "uses the provided method" do
    o = ProvidedState.new
    o.release
    o.transient_store.should eql :beta
  end

  it "uses the persistence storage" do
    o = PersistedState.new
    o.release
    o.transient_store.should be_nil
  end

  it "uses the provided method even if persisted" do
    o = ProvidedAndPersistedState.new
    o.release
    o.transient_store.should eql :beta
  end
end
