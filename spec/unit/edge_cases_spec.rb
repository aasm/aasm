require 'spec_helper'

describe "edge cases" do
  describe "for classes with multiple state machines" do
    it "allows accessing a multiple state machine class without state machine name" do
      # it's like starting to define a new state machine within the
      # requested class
      expect(SimpleMultipleExample.aasm.states.map(&:name)).to be_empty
    end

    it "do not know yet" do
      example = ComplexExampleMultiple.new
      expect { example.aasm.states.inspect }.to raise_error(AASM::UnknownStateMachineError)
    end
  end
end
