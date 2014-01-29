require 'spec_helper'
require 'models/active_record/api.rb'

describe "reading the current state" do
  it "uses the AASM default" do
    expect(DefaultState.new.aasm.current_state).to eql :alpha
  end

  it "uses the provided method" do
    expect(ProvidedState.new.aasm.current_state).to eql :beta
  end

  it "uses the persistence storage" do
    expect(PersistedState.new.aasm.current_state).to eql :alpha
  end

  it "uses the provided method even if persisted" do
    expect(ProvidedAndPersistedState.new.aasm.current_state).to eql :gamma
  end
end

describe "writing and persisting the current state" do
  it "uses the AASM default" do
    o = DefaultState.new
    o.release!
    expect(o.persisted_store).to be_nil
  end

  it "uses the provided method" do
    o = ProvidedState.new
    o.release!
    expect(o.persisted_store).to eql :beta
  end

  it "uses the persistence storage" do
    o = PersistedState.new
    o.release!
    expect(o.persisted_store).to be_nil
  end

  it "uses the provided method even if persisted" do
    o = ProvidedAndPersistedState.new
    o.release!
    expect(o.persisted_store).to eql :beta
  end
end

describe "writing the current state without persisting it" do
  it "uses the AASM default" do
    o = DefaultState.new
    o.release
    expect(o.transient_store).to be_nil
  end

  it "uses the provided method" do
    o = ProvidedState.new
    o.release
    expect(o.transient_store).to eql :beta
  end

  it "uses the persistence storage" do
    o = PersistedState.new
    o.release
    expect(o.transient_store).to be_nil
  end

  it "uses the provided method even if persisted" do
    o = ProvidedAndPersistedState.new
    o.release
    expect(o.transient_store).to eql :beta
  end
end
