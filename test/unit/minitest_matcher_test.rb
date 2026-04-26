require 'minitest_helper'

class StateMachineTest < Minitest::Spec

  let(:simple) { SimpleExample.new }
  let(:multiple) { SimpleMultipleExample.new }

  describe 'transition_from' do
    it "works for simple state machines" do
      simple.must_transition_from :initialised, to: :filled_out, on_event: :fill_out
      simple.wont_transition_from :initialised, to: :authorised, on_event: :fill_out
    end

    it "works for multiple state machines" do
      multiple.must_transition_from :standing, to: :walking, on_event: :walk, on: :move
      multiple.wont_transition_from :standing, to: :running, on_event: :walk, on: :move

      multiple.must_transition_from :sleeping, to: :processing, on_event: :start, on: :work
      multiple.wont_transition_from :sleeping, to: :sleeping, on_event: :start, on: :work
    end
  end

  describe 'allow_transition_to' do
    it "works for simple state machines" do
      simple.must_allow_transition_to :filled_out
      simple.wont_allow_transition_to :authorised
    end

    it "works for multiple state machines" do
      multiple.must_allow_transition_to :walking, on: :move
      multiple.wont_allow_transition_to :standing, on: :move

      multiple.must_allow_transition_to :processing, on: :work
      multiple.wont_allow_transition_to :sleeping, on: :work
    end
  end

  describe "have_state" do
    it "works for simple state machines" do
      simple.must_have_state :initialised
      simple.wont_have_state :filled_out
      simple.fill_out
      simple.must_have_state :filled_out
    end

    it "works for multiple state machines" do
      multiple.must_have_state :standing, on: :move
      multiple.wont_have_state :walking, on: :move
      multiple.walk
      multiple.must_have_state :walking, on: :move

      multiple.must_have_state :sleeping, on: :work
      multiple.wont_have_state :processing, on: :work
      multiple.start
      multiple.must_have_state :processing, on: :work
    end
  end

  describe "allow_event" do
    it "works for simple state machines" do
      simple.must_allow_event :fill_out
      simple.wont_allow_event :authorise
      simple.fill_out
      simple.must_allow_event :authorise
    end

    it "works for multiple state machines" do
      multiple.must_allow_event :walk, on: :move
      multiple.wont_allow_event :hold, on: :move
      multiple.walk
      multiple.must_allow_event :hold, on: :move

      multiple.must_allow_event :start, on: :work
      multiple.wont_allow_event :stop, on: :work
      multiple.start
      multiple.must_allow_event :stop, on: :work
    end
  end

end
