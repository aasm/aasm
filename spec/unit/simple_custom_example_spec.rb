require 'spec_helper'

describe 'state machine' do
  let(:simple_custom) { SimpleCustomExample.new }

  subject do
    simple_custom.fill_out!
    simple_custom.authorise
  end

  it 'has invoked authorizable?' do
    expect { subject }.to change { simple_custom.authorizable_called }.from(nil).to(true)
  end

  it 'has invoked fillable?' do
    expect { subject }.to change { simple_custom.fillable_called }.from(nil).to(true)
  end

  it 'has two transition counts' do
    expect { subject }.to change { simple_custom.transition_count }.from(nil).to(2)
  end
end
