# frozen_string_literal: true

require 'spec_helper'

if defined?(ActiveRecord)
  require 'models/active_record/with_alias'

  load_schema

  describe 'With Allias' do
    it 'should not break aasm methods' do
      with_allias = WithAlias.new
      expect(with_allias.aasm(:aasm_state_alias).current_state).to eq(:active)

      with_allias.deactivate!

      expect(with_allias.aasm_state).to eq('inactive')
      expect(with_allias.aasm(:aasm_state_alias).current_state).to eq(:inactive)
    end
  end
end
