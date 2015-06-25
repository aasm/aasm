class LocalizerTestModel < ActiveRecord::Base
  include AASM

  aasm do
    state :opened, :initial => true
    state :closed
    event :close
    event :open
  end
end

describe 'localized state names' do
  before(:all) do
    I18n.load_path << 'spec/en.yml'
    I18n.default_locale = :en
    I18n.reload!
  end

  after(:all) do
    I18n.load_path.clear
  end

  it 'should localize' do
    state = LocalizerTestModel.aasm.states.detect {|s| s == :opened}
    expect(state.localized_name).to eq("It's open now!")
    expect(state.human_name).to eq("It's open now!")
  end

  it 'should use fallback' do
    state = LocalizerTestModel.aasm.states.detect {|s| s == :closed}
    expect(state.localized_name).to eq('Closed')
    expect(state.human_name).to eq('Closed')
  end
end
