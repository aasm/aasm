require 'test_helper'

class StateTest < Test::Unit::TestCase
  def new_state(options={})
    AASM::SupportingClasses::State.new(@name, @options.merge(options))
  end
  
  context 'state' do
    setup do
      @name = :astate
      @options = { :crazy_custom_key => 'key' }
    end
    
    should 'set the name' do
      assert_equal :astate, new_state.name
    end
    
    should 'set the display_name from name' do
      assert_equal "Astate", new_state.display_name
    end
    
    should 'set the display_name from options' do
      assert_equal "A State", new_state(:display => "A State").display_name
    end
    
    should 'set the options and expose them as options' do
      assert_equal @options, new_state.options
    end
    
    should 'equal a symbol of the same name' do
      assert_equal new_state, :astate
    end
    
    should 'equal a state of the same name' do
      assert_equal new_state, new_state
    end
    
    should 'send a message to the record for an action if the action is present as a symbol' do
      state = new_state(:entering => :foo)
      mock(record = Object.new).foo
      state.call_action(:entering, record)
    end
    
    should 'send a message to the record for an action if the action is present as a string' do
      state = new_state(:entering => 'foo')
      mock(record = Object.new).foo
      state.call_action(:entering, record)
    end
    
    should 'call a proc with the record as its argument for an action if the action is present as a proc' do
      state = new_state(:entering => Proc.new {|r| r.foobar})
      mock(record = Object.new).foobar
      state.call_action(:entering, record)
    end
    
    should 'send a message to the record for each action if the action is present as an array' do
      state = new_state(:entering => [:a, :b, 'c', lambda {|r| r.foobar}])
      
      record = Object.new
      mock(record).a
      mock(record).b
      mock(record).c
      mock(record).foobar
      
      state.call_action(:entering, record)
    end
    
  end
end
