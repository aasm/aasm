require 'spec_helper'

describe "dsl with custom ASM::Base and custom core classes" do

  let(:example) {FullExampleWithCustomAasmBase.new}

  it 'should create the expected state machine' do
    aasm = example.aasm(:default)

    state = aasm.states.first
    expect(state).to be_a(CustomState)

    event = aasm.events.first
    expect(event).to be_a(CustomEvent)
    expect(event.some_option).to eq('-- some event value --')
    expect(event.another_option).to eq(['-- another event value --'])
    expect(event.custom_method_args).to eq(41)

    transition = event.transitions.first
    expect(transition).to be_a(CustomTransition)
    expect(transition.some_option).to eq('-- some transition value --')
    expect(transition.another_option).to eq(['-- another transition value --'])
    expect(transition.custom_method_args).to eq(42)
  end

end
