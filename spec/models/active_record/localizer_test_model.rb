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
    I18n.load_path << 'spec/localizer_test_model_new_style.yml'
    I18n.reload!
  end

  after(:all) do
    I18n.load_path.delete('spec/localizer_test_model_new_style.yml')
    I18n.backend.load_translations
  end

  it 'should localize' do
    state = LocalizerTestModel.aasm.states.detect {|s| s == :opened}
    expect(state.localized_name).to eq("It's open now!")
    expect(state.human_name).to eq("It's open now!")
    expect(state.display_name).to eq("It's open now!")

    I18n.with_locale(:fr) do
      expect(state.localized_name).to eq("C'est ouvert maintenant!")
      expect(state.human_name).to eq("C'est ouvert maintenant!")
      expect(state.display_name).to eq("C'est ouvert maintenant!")
    end
  end

  it 'should use fallback' do
    state = LocalizerTestModel.aasm.states.detect {|s| s == :closed}
    expect(state.localized_name).to eq('Closed')
    expect(state.human_name).to eq('Closed')
    expect(state.display_name).to eq('Closed')
  end
end
