require 'spec_helper'

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

describe AASM::Transition do
  it 'should set from, to, and opts attr readers' do
    opts = {:from => 'foo', :to => 'bar', :guard => 'g'}
    st = AASM::Transition.new(opts)

    st.from.should == opts[:from]
    st.to.should == opts[:to]
    st.opts.should == opts
  end

  it 'should set on_transition with deprecation warning' do
    opts = {:from => 'foo', :to => 'bar'}
    st = AASM::Transition.allocate
    st.should_receive(:warn).with('[DEPRECATION] :on_transition is deprecated, use :after instead')

    st.send :initialize, opts do
      guard :gg
      on_transition :after_callback
    end

    st.opts[:after].should == [:after_callback]
  end

  it 'should set after and guard from dsl' do
    opts = {:from => 'foo', :to => 'bar', :guard => 'g'}
    st = AASM::Transition.new(opts) do
      guard :gg
      after :after_callback
    end

    st.opts[:guard].should == ['g', :gg]
    st.opts[:after].should == [:after_callback] # TODO fix this bad code coupling
  end

  it 'should pass equality check if from and to are the same' do
    opts = {:from => 'foo', :to => 'bar', :guard => 'g'}
    st = AASM::Transition.new(opts)

    obj = mock('object')
    obj.stub!(:from).and_return(opts[:from])
    obj.stub!(:to).and_return(opts[:to])

    st.should == obj
  end

  it 'should fail equality check if from are not the same' do
    opts = {:from => 'foo', :to => 'bar', :guard => 'g'}
    st = AASM::Transition.new(opts)

    obj = mock('object')
    obj.stub!(:from).and_return('blah')
    obj.stub!(:to).and_return(opts[:to])

    st.should_not == obj
  end

  it 'should fail equality check if to are not the same' do
    opts = {:from => 'foo', :to => 'bar', :guard => 'g'}
    st = AASM::Transition.new(opts)

    obj = mock('object')
    obj.stub!(:from).and_return(opts[:from])
    obj.stub!(:to).and_return('blah')

    st.should_not == obj
  end
end

describe AASM::Transition, '- when performing guard checks' do
  it 'should return true of there is no guard' do
    opts = {:from => 'foo', :to => 'bar'}
    st = AASM::Transition.new(opts)

    st.perform(nil).should be_true
  end

  it 'should call the method on the object if guard is a symbol' do
    opts = {:from => 'foo', :to => 'bar', :guard => :test}
    st = AASM::Transition.new(opts)

    obj = mock('object')
    obj.should_receive(:test)

    st.perform(obj)
  end

  it 'should call the method on the object if guard is a string' do
    opts = {:from => 'foo', :to => 'bar', :guard => 'test'}
    st = AASM::Transition.new(opts)

    obj = mock('object')
    obj.should_receive(:test)

    st.perform(obj)
  end

  it 'should call the proc passing the object if the guard is a proc' do
    opts = {:from => 'foo', :to => 'bar', :guard => Proc.new { test }}
    st = AASM::Transition.new(opts)

    obj = mock('object')
    obj.should_receive(:test)

    st.perform(obj)
  end
end

describe AASM::Transition, '- when executing the transition with a Proc' do
  it 'should call a Proc on the object with args' do
    opts = {:from => 'foo', :to => 'bar', :after => Proc.new {|a| test(a) }}
    st = AASM::Transition.new(opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = mock('object')

    obj.should_receive(:test).with(args)

    st.execute(obj, args)
  end

  it 'should call a Proc on the object without args' do
    prc = Proc.new {||}
    opts = {:from => 'foo', :to => 'bar', :after => prc }
    st = AASM::Transition.new(opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = mock('object')

    obj.should_receive(:instance_exec).with(no_args)  # FIXME bad spec

    st.execute(obj, args)
  end
end

describe AASM::Transition, '- when executing the transition with an :after method call' do
  it 'should accept a String for the method name' do
    opts = {:from => 'foo', :to => 'bar', :after => 'test'}
    st = AASM::Transition.new(opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = mock('object')

    obj.should_receive(:test)

    st.execute(obj, args)
  end

  it 'should accept a Symbol for the method name' do
    opts = {:from => 'foo', :to => 'bar', :after => :test}
    st = AASM::Transition.new(opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = mock('object')

    obj.should_receive(:test)

    st.execute(obj, args)
  end

  it 'should pass args if the target method accepts them' do
    opts = {:from => 'foo', :to => 'bar', :after => :test}
    st = AASM::Transition.new(opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = mock('object')

    obj.class.class_eval do
      define_method(:test) {|*args| 'success'}
    end

    return_value = st.execute(obj, args)

    return_value.should == 'success'
  end

  it 'should NOT pass args if the target method does NOT accept them' do
    opts = {:from => 'foo', :to => 'bar', :after => :test}
    st = AASM::Transition.new(opts)
    args = {:arg1 => '1', :arg2 => '2'}
    obj = mock('object')

    obj.class.class_eval do
      define_method(:test) {|*args| 'success'}
    end

    return_value = st.execute(obj, args)

    return_value.should == 'success'
  end

end
