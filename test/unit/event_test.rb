require 'test_helper'

class EventTest < Test::Unit::TestCase
  def new_event
    @event = AASM::SupportingClasses::Event.new(@name, {:success => @success}) do
      transitions :to => :closed, :from => [:open, :received]
    end
  end
  
  context 'event' do
    setup do
      @name = :close_order
      @success = :success_callback
    end
    
    should 'set the name' do
      assert_equal @name, new_event.name
    end
    
    should 'set the success option' do
      assert_equal @success, new_event.success
    end
    
    should 'create StateTransitions' do
      mock(AASM::SupportingClasses::StateTransition).new({:to => :closed, :from => :open})
      mock(AASM::SupportingClasses::StateTransition).new({:to => :closed, :from => :received})
      new_event
    end
    
    context 'when firing' do
      should 'raise an AASM::InvalidTransition error if the transitions are empty' do
        event = AASM::SupportingClasses::Event.new(:event)
        
        obj = OpenStruct.new
        obj.aasm_current_state = :open
        
        assert_raise AASM::InvalidTransition do
          event.fire(obj)
        end
      end
      
      should 'return the state of the first matching transition it finds' do
        event = AASM::SupportingClasses::Event.new(:event) do
          transitions :to => :closed, :from => [:open, :received]
        end

        obj = OpenStruct.new
        obj.aasm_current_state = :open

        assert_equal :closed, event.fire(obj)
      end
    end
  end
end
