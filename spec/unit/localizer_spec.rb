require 'spec_helper'

if defined?(ActiceRecord)
  require 'i18n'

  I18n.enforce_available_locales = false
  load_schema

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

    context 'aasm.human_event_name' do
      it 'should return translated event name' do
        expect(LocalizerTestModel.aasm.human_event_name(:close)).to eq("Let's close it!")
      end

      it 'should return humanized event name' do
        expect(LocalizerTestModel.aasm.human_event_name(:open)).to eq("Open")
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

    context 'aasm.human_event_name' do
      it 'should return translated event name' do
        expect(LocalizerTestModel.aasm.human_event_name(:close)).to eq("Let's close it!")
      end

      it 'should return humanized event name' do
        expect(LocalizerTestModel.aasm.human_event_name(:open)).to eq("Open")
      end
    end
  end
end
