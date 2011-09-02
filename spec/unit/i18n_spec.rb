require 'spec_helper'
require 'active_record'
require 'logger'
require 'i18n'

ActiveRecord::Base.logger = Logger.new(STDERR)

class I18nTestModel < ActiveRecord::Base
  include AASM

  attr_accessor :aasm_state

  aasm_initial_state :open
  aasm_state :opened
  aasm_state :closed

  aasm_event :close
  aasm_event :open
end

describe AASM::I18n do
  before(:all) do
    I18n.load_path << 'spec/en.yml'
    I18n.default_locale = :en
  end

  after(:all) { I18n.load_path.clear }

  let (:foo_opened) { I18nTestModel.new }
  let (:foo_closed) { I18nTestModel.new.tap { |x| x.aasm_state = :closed  } }

  context '.human_state' do
    it 'should return translated state value' do
       foo_opened.human_state.should == "It's opened now!"
    end

    it 'should return humanized value if not localized' do
      foo_closed.human_state.should == "Closed"
    end
  end

  context '.human_event_name' do
    it 'should return translated event name' do
      I18nTestModel.human_event_name(:close).should == "Let's close it!"
    end

    it 'should return humanized event name' do
      I18nTestModel.human_event_name(:open).should == "Open"
    end
  end
end
