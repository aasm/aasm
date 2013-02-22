require 'spec_helper'
require 'active_record'
require 'logger'
require 'i18n'

load_schema

class LocalizerTestModel < ActiveRecord::Base
  include AASM

  attr_accessor :aasm_state

  aasm_initial_state :opened
  aasm_state :opened
  aasm_state :closed

  aasm_event :close
  aasm_event :open
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
    LocalizerTestModel.aasm.states.detect {|s| s == :opened}.localized_name.should == "It's open now!"
  end

  it 'should use fallback' do
    LocalizerTestModel.aasm.states.detect {|s| s == :closed}.localized_name.should == 'Closed'
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

  context 'aasm_human_state' do
    it 'should return translated state value' do
      foo_opened.aasm_human_state.should == "It's open now!"
    end

    it 'should return humanized value if not localized' do
      foo_closed.aasm_human_state.should == "Closed"
    end
  end

  context 'aasm_human_event_name' do
    it 'should return translated event name' do
      LocalizerTestModel.aasm_human_event_name(:close).should == "Let's close it!"
    end

    it 'should return humanized event name' do
      LocalizerTestModel.aasm_human_event_name(:open).should == "Open"
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

  context 'aasm_human_state' do
    it 'should return translated state value' do
      foo_opened.aasm_human_state.should == "It's open now!"
    end

    it 'should return humanized value if not localized' do
      foo_closed.aasm_human_state.should == "Closed"
    end
  end

  context 'aasm_human_event_name' do
    it 'should return translated event name' do
      LocalizerTestModel.aasm_human_event_name(:close).should == "Let's close it!"
    end

    it 'should return humanized event name' do
      LocalizerTestModel.aasm_human_event_name(:open).should == "Open"
    end
  end
end
