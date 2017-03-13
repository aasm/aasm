require 'spec_helper'

describe "nil as first argument" do
  let(:guard) { WrongArgumentsList.new }

  it 'does not raise errors' do
    expect { guard.mark_as_reviewed(nil, 'yuppi') }.not_to raise_error
  end
end
