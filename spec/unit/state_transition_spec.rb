require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe 'transitions' do

  it 'should raise an exception when whiny' do
    process = ProcessWithNewDsl.new
    lambda { process.stop! }.should raise_error(AASM::InvalidTransition)
    process.should be_sleeping
  end

  it 'should not raise an exception when not whiny' do
    silencer = Silencer.new
    silencer.smile!.should be_false
    silencer.should be_silent
  end

  it 'should not raise an exception when superclass not whiny' do
    sub = SubClassing.new
    sub.smile!.should be_false
    sub.should be_silent
  end

  it 'should not raise an exception when from is nil even if whiny' do
    silencer = Silencer.new
    silencer.smile_any!.should be_true
    silencer.should be_smiling
  end
  
end

describe AASM::SupportingClasses::StateTransition do
  it 'should set from, to, and opts attr readers' do
    opts = {:from => 'foo', :to => 'bar', :guard => 'g'}
    st = AASM::SupportingClasses::StateTransition.new(opts)

    st.from.should == opts[:from]
    st.to.should == opts[:to]
    st.opts.should == opts
  end

  it 'should pass equality check if from and to are the same' do
    opts = {:from => 'foo', :to => 'bar', :guard => 'g'}
    st = AASM::SupportingClasses::StateTransition.new(opts)

    obj = mock('object')
    obj.stub!(:from).and_return(opts[:from])
    obj.stub!(:to).and_return(opts[:to])

    st.should == obj
  end

  it 'should fail equality check if from are not the same' do
    opts = {:from => 'foo', :to => 'bar', :guard => 'g'}
    st = AASM::SupportingClasses::StateTransition.new(opts)

    obj = mock('object')
    obj.stub!(:from).and_return('blah')
    obj.stub!(:to).and_return(opts[:to])

    st.should_not == obj
  end

  it 'should fail equality check if to are not the same' do
    opts = {:from => 'foo', :to => 'bar', :guard => 'g'}
    st = AASM::SupportingClasses::StateTransition.new(opts)

    obj = mock('object')
    obj.stub!(:from).and_return(opts[:from])
    obj.stub!(:to).and_return('blah')

    st.should_not == obj
  end
end

describe AASM::SupportingClasses::StateTransition, '- when performing guard checks' do
  it 'should return true of there is no guard' do
    opts = {:from => 'foo', :to => 'bar'}
    st = AASM::SupportingClasses::StateTransition.new(opts)

    st.perform(nil).should be_true
  end

  it 'should call the method on the object if guard is a symbol' do
    opts = {:from => 'foo', :to => 'bar', :guard => :test}
    st = AASM::SupportingClasses::StateTransition.new(opts)

    obj = mock('object')
    obj.should_receive(:test)

    st.perform(obj)
  end

  it 'should call the method on the object if guard is a string' do
    opts = {:from => 'foo', :to => 'bar', :guard => 'test'}
    st = AASM::SupportingClasses::StateTransition.new(opts)

    obj = mock('object')
    obj.should_receive(:test)

    st.perform(obj)
  end

  it 'should call the proc passing the object if the guard is a proc' do
    opts = {:from => 'foo', :to => 'bar', :guard => Proc.new {|o| o.test}}
    st = AASM::SupportingClasses::StateTransition.new(opts)

    obj = mock('object')
    obj.should_receive(:test)

    st.perform(obj)
  end
end

describe AASM::SupportingClasses::StateTransition, '- when executing the transition with a Proc' do
  it 'should call a Proc on the object with args' do
    opts = {:from => 'foo', :to => 'bar', :on_transition => Proc.new {|o| o.test}}
    st = AASM::SupportingClasses::StateTransition.new(opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = mock('object')

    opts[:on_transition].should_receive(:call).with(any_args)

    st.execute(obj, args)
  end

  it 'should call a Proc on the object without args' do
    opts = {:from => 'foo', :to => 'bar', :on_transition => Proc.new {||}}
    st = AASM::SupportingClasses::StateTransition.new(opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = mock('object')

    opts[:on_transition].should_receive(:call).with(no_args)

    st.execute(obj, args)
  end
end

describe AASM::SupportingClasses::StateTransition, '- when executing the transition with an :on_transtion method call' do
  it 'should accept a String for the method name' do
    opts = {:from => 'foo', :to => 'bar', :on_transition => 'test'}
    st = AASM::SupportingClasses::StateTransition.new(opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = mock('object')

    obj.should_receive(:test)

    st.execute(obj, args)
  end

  it 'should accept a Symbol for the method name' do
    opts = {:from => 'foo', :to => 'bar', :on_transition => :test}
    st = AASM::SupportingClasses::StateTransition.new(opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = mock('object')

    obj.should_receive(:test)

    st.execute(obj, args)
  end

  it 'should pass args if the target method accepts them' do
    opts = {:from => 'foo', :to => 'bar', :on_transition => :test}
    st = AASM::SupportingClasses::StateTransition.new(opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = mock('object')

    obj.class.class_eval do
      define_method(:test) {|*args| 'success'}
    end

    return_value = st.execute(obj, args)

    return_value.should == 'success'
  end

  it 'should NOT pass args if the target method does NOT accept them' do
    opts = {:from => 'foo', :to => 'bar', :on_transition => :test}
    st = AASM::SupportingClasses::StateTransition.new(opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = mock('object')

    obj.class.class_eval do
      define_method(:test) {|*args| 'success'}
    end

    return_value = st.execute(obj, args)

    return_value.should == 'success'
  end

end
