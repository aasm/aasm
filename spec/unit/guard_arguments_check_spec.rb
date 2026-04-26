require 'spec_helper'

describe "nil as first argument" do
  let(:guard) { GuardArgumentsCheck.new }

  it 'does not raise errors' do
    expect { guard.mark_as_reviewed(nil, 'second arg') }.not_to raise_error
  end
end
