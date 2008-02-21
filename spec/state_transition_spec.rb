require File.join(File.dirname(__FILE__), '..', 'lib', 'state_transition')

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

