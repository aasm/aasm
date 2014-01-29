require 'spec_helper'
require 'active_record'
require 'logger'
require 'i18n'

load_schema

class LocalizerTestModel < ActiveRecord::Base
  include AASM

  attr_accessor :aasm_state

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

describe AASM::Localizer, "new style" do
  before(:all) do
    I18n.load_path << 'spec/en.yml'
    I18n.default_locale = :en
    I18n.reload!
  end

  after(:all) do
    I18n.load_path.clear
  end

  let (:foo_opened) { LocalizerTestModel.new }
  let (:foo_closed) { LocalizerTestModel.new.tap { |x| x.aasm_state = :closed  } }

  context 'aasm.human_state' do
    it 'should return translated state value' do
      expect(foo_opened.aasm.human_state).to eq("It's open now!")
    end

    it 'should return humanized value if not localized' do
      expect(foo_closed.aasm.human_state).to eq("Closed")
    end
  end

  context 'aasm_human_event_name' do
    it 'should return translated event name' do
      expect(LocalizerTestModel.aasm_human_event_name(:close)).to eq("Let's close it!")
    end

    it 'should return humanized event name' do
      expect(LocalizerTestModel.aasm_human_event_name(:open)).to eq("Open")
    end
  end
end

describe AASM::Localizer, "deprecated style" do
  before(:all) do
    I18n.load_path << 'spec/en_deprecated_style.yml'
    I18n.default_locale = :en
    I18n.reload!
  end

  after(:all) do
    I18n.load_path.clear
  end

  let (:foo_opened) { LocalizerTestModel.new }
  let (:foo_closed) { LocalizerTestModel.new.tap { |x| x.aasm_state = :closed  } }

  context 'aasm.human_state' do
    it 'should return translated state value' do
      expect(foo_opened.aasm.human_state).to eq("It's open now!")
    end

    it 'should return humanized value if not localized' do
      expect(foo_closed.aasm.human_state).to eq("Closed")
    end
  end

  context 'aasm_human_event_name' do
    it 'should return translated event name' do
      expect(LocalizerTestModel.aasm_human_event_name(:close)).to eq("Let's close it!")
    end

    it 'should return humanized event name' do
      expect(LocalizerTestModel.aasm_human_event_name(:open)).to eq("Open")
    end
  end
end
