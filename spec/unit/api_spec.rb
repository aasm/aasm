require 'spec_helper'

if defined?(ActiveRecord)
  require 'models/default_state.rb'
  require 'models/provided_state.rb'
  require 'models/active_record/persisted_state.rb'
  require 'models/active_record/provided_and_persisted_state.rb'

  load_schema

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

    context "after dup" do
      it "uses the persistence storage" do
        source = PersistedState.create!
        copy = source.dup
        copy.save!

        copy.release!

        expect(source.aasm_state).to eql 'alpha'
        expect(source.aasm.current_state).to eql :alpha

        source2 = PersistedState.find(source.id)
        expect(source2.reload.aasm_state).to eql 'alpha'
        expect(source2.aasm.current_state).to eql :alpha

        expect(copy.aasm_state).to eql 'beta'
        expect(copy.aasm.current_state).to eql :beta
      end
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
end
