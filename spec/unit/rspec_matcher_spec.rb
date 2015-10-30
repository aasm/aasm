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
end
