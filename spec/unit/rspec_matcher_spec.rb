require 'spec_helper'

describe 'state machine' do
  let(:simple) { SimpleExample.new }
  let(:multiple) { SimpleMultipleExample.new }

  describe 'transition_from' do
    it "works for simple state machines" do
      expect(simple).to transition_from(:initialised).to(:filled_out).on_event(:fill_out)
      expect(simple).to_not transition_from(:initialised).to(:authorised).on_event(:fill_out)
    end

    it "works for multiple state machines" do
      expect(multiple).to transition_from(:standing).to(:walking).on_event(:walk).on(:move)
      expect(multiple).to_not transition_from(:standing).to(:running).on_event(:walk).on(:move)

      expect(multiple).to transition_from(:sleeping).to(:processing).on_event(:start).on(:work)
      expect(multiple).to_not transition_from(:sleeping).to(:sleeping).on_event(:start).on(:work)
    end
  end

  describe 'allow_transition_to' do
    it "works for simple state machines" do
      expect(simple).to allow_transition_to(:filled_out)
      expect(simple).to_not allow_transition_to(:authorised)
    end

    it "works for multiple state machines" do
      expect(multiple).to allow_transition_to(:walking).on(:move)
      expect(multiple).to_not allow_transition_to(:standing).on(:move)

      expect(multiple).to allow_transition_to(:processing).on(:work)
      expect(multiple).to_not allow_transition_to(:sleeping).on(:work)
    end
  end

  describe "have_state" do
    it "works for simple state machines" do
      expect(simple).to have_state :initialised
      expect(simple).to_not have_state :filled_out
      simple.fill_out
      expect(simple).to have_state :filled_out
    end

    it "works for multiple state machines" do
      expect(multiple).to have_state(:standing).on(:move)
      expect(multiple).to_not have_state(:walking).on(:move)
      multiple.walk
      expect(multiple).to have_state(:walking).on(:move)

      expect(multiple).to have_state(:sleeping).on(:work)
      expect(multiple).to_not have_state(:processing).on(:work)
      multiple.start
      expect(multiple).to have_state(:processing).on(:work)
    end
  end

  describe "allow_event" do
    it "works for simple state machines" do
      expect(simple).to allow_event :fill_out
      expect(simple).to_not allow_event :authorise
      simple.fill_out
      expect(simple).to allow_event :authorise
    end

    it "works with custom arguments" do
      example = SimpleExampleWithGuardArgs.new
      expect(example).to allow_event(:fill_out_with_args).with(true)
      expect(example).to_not allow_event(:fill_out_with_args).with(false)
    end

    it "works for multiple state machines" do
      expect(multiple).to allow_event(:walk).on(:move)
      expect(multiple).to_not allow_event(:hold).on(:move)
      multiple.walk
      expect(multiple).to allow_event(:hold).on(:move)

      expect(multiple).to allow_event(:start).on(:work)
      expect(multiple).to_not allow_event(:stop).on(:work)
      multiple.start
      expect(multiple).to allow_event(:stop).on(:work)
    end
  end

end
