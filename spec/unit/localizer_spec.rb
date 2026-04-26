require 'spec_helper'

if defined?(ActiveRecord)
  require 'models/active_record/localizer_test_model'
  load_schema

  describe AASM::Localizer, "new style" do
    before(:all) do
      I18n.load_path << 'spec/localizer_test_model_new_style.yml'
      I18n.reload!
    end

    after(:all) do
      I18n.load_path.delete('spec/localizer_test_model_new_style.yml')
      I18n.backend.load_translations
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
      context 'with event name' do
        it 'should return translated event name' do
          expect(LocalizerTestModel.aasm.human_event_name(:close)).to eq("Let's close it!")
        end

        it 'should return humanized event name' do
          expect(LocalizerTestModel.aasm.human_event_name(:open)).to eq("Open")
        end
      end

      context 'with event object' do
        it 'should return translated event name' do
          event = LocalizerTestModel.aasm.events.detect { |e| e.name == :close }

          expect(LocalizerTestModel.aasm.human_event_name(event)).to eq("Let's close it!")
        end

        it 'should return humanized event name' do
          event = LocalizerTestModel.aasm.events.detect { |e| e.name == :open }

          expect(LocalizerTestModel.aasm.human_event_name(event)).to eq("Open")
        end
      end
    end
  end

  describe AASM::Localizer, "deprecated style" do
    before(:all) do
      I18n.load_path << 'spec/localizer_test_model_deprecated_style.yml'
      I18n.reload!
      I18n.backend.load_translations
    end

    after(:all) do
      I18n.load_path.delete('spec/localizer_test_model_deprecated_style.yml')
      I18n.backend.load_translations
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
      context 'with event name' do
        it 'should return translated event name' do
          expect(LocalizerTestModel.aasm.human_event_name(:close)).to eq("Let's close it!")
        end

        it 'should return humanized event name' do
          expect(LocalizerTestModel.aasm.human_event_name(:open)).to eq("Open")
        end
      end

      context 'with event object' do
        it 'should return translated event name' do
          event = LocalizerTestModel.aasm.events.detect { |e| e.name == :close }

          expect(LocalizerTestModel.aasm.human_event_name(event)).to eq("Let's close it!")
        end

        it 'should return humanized event name' do
          event = LocalizerTestModel.aasm.events.detect { |e| e.name == :open }

          expect(LocalizerTestModel.aasm.human_event_name(event)).to eq("Open")
        end
      end
    end
  end
end
