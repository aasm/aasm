require 'test_helper'

class StateTransitionTest < Test::Unit::TestCase
  context 'state transition' do
    setup do
      @opts = {:from => 'foo', :to => 'bar', :guard => 'g'}
      @st = AASM::SupportingClasses::StateTransition.new(@opts)
    end
    
    should 'set from, to, and opts attr readers' do
      assert_equal @opts[:from], @st.from
      assert_equal @opts[:to], @st.to
      assert_equal @opts, @st.options
    end
    
    should 'pass equality check if from and to are the same' do
      obj = OpenStruct.new
      obj.from = @opts[:from]
      obj.to = @opts[:to]
      
      assert_equal @st, obj
    end
    
    should 'fail equality check if from is not the same' do
      obj = OpenStruct.new
      obj.from = 'blah'
      obj.to = @opts[:to]
      
      assert_not_equal @st, obj
    end
    
    should 'fail equality check if to is not the same' do
      obj = OpenStruct.new
      obj.from = @opts[:from]
      obj.to = 'blah'
      
      assert_not_equal @st, obj
    end
    
    context 'when performing guard checks' do
      should 'return true if there is no guard' do
        opts = {:from => 'foo', :to => 'bar'}
        st = AASM::SupportingClasses::StateTransition.new(opts)
        assert st.perform(nil)
      end
      
      should 'call the method on the object if guard is a symbol' do
        opts = {:from => 'foo', :to => 'bar', :guard => :test_guard}
        st = AASM::SupportingClasses::StateTransition.new(opts)

        mock(obj = Object.new).test_guard

        st.perform(obj)
      end
      
      should 'call the method on the object if guard is a string' do
        opts = {:from => 'foo', :to => 'bar', :guard => 'test_guard'}
        st = AASM::SupportingClasses::StateTransition.new(opts)

        mock(obj = Object.new).test_guard

        st.perform(obj)
      end
      
      should 'call the proc passing the object if guard is a proc' do
        opts = {:from => 'foo', :to => 'bar', :guard => Proc.new {|o| o.test_guard}}
        st = AASM::SupportingClasses::StateTransition.new(opts)

        mock(obj = Object.new).test_guard

        st.perform(obj)
      end 
    end
  end
end
