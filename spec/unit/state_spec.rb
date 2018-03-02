require 'spec_helper'

describe AASM::Core::State do
  let(:state_machine) { AASM::StateMachine.new(:name) }

  before(:each) do
    @name    = :astate
    @options = { :crazy_custom_key => 'key' }
  end

  def new_state(options={})
    AASM::Core::State.new(@name, Conversation, state_machine, @options.merge(options))
  end

  it 'should set the name' do
    state = new_state
    expect(state.name).to eq(:astate)
  end

  it 'should set the display_name from name' do
    expect(new_state.display_name).to eq('Astate')
  end

  it 'should set the display_name from options' do
    expect(new_state(:display => "A State").display_name).to eq('A State')
  end

  it 'should set the options and expose them as options' do
    expect(new_state.options).to eq(@options)
  end

  it 'should be equal to a symbol of the same name' do
    expect(new_state).to eq(:astate)
  end

  it 'should be equal to a State of the same name' do
    expect(new_state).to eq(new_state)
  end

  it 'should send a message to the record for an action if the action is present as a symbol' do
    state = new_state(:entering => :foo)

    record = double('record')
    expect(record).to receive(:foo)

    state.fire_callbacks(:entering, record)
  end

  it 'should send a message to the record for an action if the action is present as a string' do
    state = new_state(:entering => 'foo')

    record = double('record')
    expect(record).to receive(:foo)

    state.fire_callbacks(:entering, record)
  end

  it 'should send a message to the record for each action' do
    state = new_state(:entering => [:a, :b, "c", lambda {|r| r.foobar }])

    record = double('record')
    expect(record).to receive(:a)
    expect(record).to receive(:b)
    expect(record).to receive(:c)
    expect(record).to receive(:foobar)

    state.fire_callbacks(:entering, record, record)
  end

  it "should stop calling actions if one of them raises :halt_aasm_chain" do
    state = new_state(:entering => [:a, :b, :c])

    record = double('record')
    expect(record).to receive(:a)
    expect(record).to receive(:b).and_throw(:halt_aasm_chain)
    expect(record).not_to receive(:c)

    state.fire_callbacks(:entering, record)
  end

  it 'should call a proc, passing in the record for an action if the action is present' do
    state = new_state(:entering => Proc.new {|r| r.foobar})

    record = double('record')
    expect(record).to receive(:foobar)

    state.fire_callbacks(:entering, record, record)
  end
end
