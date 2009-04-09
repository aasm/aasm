require File.join(File.dirname(__FILE__), '..', 'spec_helper')

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
