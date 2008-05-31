require File.join(File.dirname(__FILE__), '..', 'spec_helper')

# TODO These are specs ported from original aasm
describe AASM::SupportingClasses::State do
  before(:each) do
    @name    = :astate
    @options = { :crazy_custom_key => 'key' }
  end

  def new_state(options={})
    AASM::SupportingClasses::State.new(@name, @options.merge(options))
  end

  it 'should set the name' do
    state = new_state

    state.name.should == :astate
  end
  
  it 'should set the options and expose them as options' do
    state = new_state
    
    state.options.should == @options
  end

  it 'should be equal to a symbol of the same name' do
    state = new_state

    state.should == :astate
  end

  it 'should be equal to a State of the same name' do
    new_state.should == new_state
  end

  it 'should send a message to the record for an action if the action is present as a symbol' do
    state = new_state(:entering => :foo)

    record = mock('record')
    record.should_receive(:foo)

    state.call_action(:entering, record)
  end

  it 'should send a message to the record for an action if the action is present as a string' do
    state = new_state(:entering => 'foo')

    record = mock('record')
    record.should_receive(:foo)

    state.call_action(:entering, record)
  end

  it 'should call a proc, passing in the record for an action if the action is present' do
    state = new_state(:entering => Proc.new {|r| r.foobar})

    record = mock('record')
    record.should_receive(:foobar)
    
    state.call_action(:entering, record)
  end
end
