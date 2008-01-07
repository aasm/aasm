require File.join(File.dirname(__FILE__), '..', 'lib', 'state_transition')

describe AASM::SupportingClasses::StateTransition do
  it 'should set from, to, and opts attr readers' do
    opts = {:from => 'foo', :to => 'bar', :guard => 'g'}
    st = AASM::SupportingClasses::StateTransition.new(opts)

    st.from.should == opts[:from]
    st.to.should == opts[:to]
    st.opts.should == opts
  end
end

