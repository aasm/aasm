require 'spec_helper'

if defined?(NoBrainer::Document)
  describe 'nobrainer' do
    Dir[File.dirname(__FILE__) + '/../../models/nobrainer/*.rb'].sort.each do |f|
      require File.expand_path(f)
    end

    before(:all) do
      # if you want to see the statements while running the spec enable the
      # following line
      # NoBrainer.configure do |config|
      #   config.logger = Logger.new(STDERR)
      # end
    end

    after do
      NoBrainer.purge!
    end

    describe 'named scopes with the old DSL' do
      context 'Does not already respond_to? the scope name' do
        it 'should add a scope for each state' do
          expect(SimpleNoBrainer).to respond_to(:unknown_scope)
          expect(SimpleNoBrainer).to respond_to(:another_unknown_scope)

          expect(SimpleNoBrainer.unknown_scope.class).to eq(NoBrainer::Criteria)
          expect(SimpleNoBrainer.another_unknown_scope.class).to eq(NoBrainer::Criteria)
        end
      end

      context 'Already respond_to? the scope name' do
        it 'should not add a scope' do
          expect(SimpleNoBrainer).to respond_to(:new)
          expect(SimpleNoBrainer.new.class).to eq(SimpleNoBrainer)
        end
      end
    end

    describe 'named scopes with the new DSL' do
      context 'Does not already respond_to? the scope name' do
        it 'should add a scope' do
          expect(SimpleNewDslNoBrainer).to respond_to(:unknown_scope)
          expect(SimpleNewDslNoBrainer.unknown_scope.class).to eq(NoBrainer::Criteria)
        end
      end

      context 'Already respond_to? the scope name' do
        it 'should not add a scope' do
          expect(SimpleNewDslNoBrainer).to respond_to(:new)
          expect(SimpleNewDslNoBrainer.new.class).to eq(SimpleNewDslNoBrainer)
        end
      end

      it 'does not create scopes if requested' do
        expect(NoScopeNoBrainer).not_to respond_to(:ignored_scope)
      end
    end

    describe 'instance methods' do
      let(:simple) { SimpleNewDslNoBrainer.new }

      it 'should initialize the aasm state on instantiation' do
        expect(SimpleNewDslNoBrainer.new.status).to eql 'unknown_scope'
        expect(SimpleNewDslNoBrainer.new.aasm.current_state).to eql :unknown_scope
      end
    end

    describe 'relations object' do
      it 'should load relations object ids' do
        parent  = Parent.create
        child_1 = Child.create(parent_id: parent.id)
        child_2 = Child.create(parent_id: parent.id)
        expect(parent.childs.pluck(:id, :status).map(&:id)).to eql [child_1.id, child_2.id]
      end
    end

    describe 'transitions with persistence' do
      it 'should work for valid models' do
        valid_object = ValidatorNoBrainer.create(name: 'name')
        expect(valid_object).to be_sleeping
        valid_object.status = :running
        expect(valid_object).to be_running
      end

      it 'should not store states for invalid models' do
        validator = ValidatorNoBrainer.create(name: 'name')
        expect(validator).to be_valid
        expect(validator).to be_sleeping

        validator.name = nil
        expect(validator).not_to be_valid
        expect { validator.run! }.to raise_error(NoBrainer::Error::DocumentInvalid)
        expect(validator).to be_sleeping

        validator.reload
        expect(validator).not_to be_running
        expect(validator).to be_sleeping

        validator.name = 'another name'
        expect(validator).to be_valid
        expect(validator.run!).to be_truthy
        expect(validator).to be_running

        validator.reload
        expect(validator).to be_running
        expect(validator).not_to be_sleeping
      end

      it 'should not store states for invalid models silently if configured' do
        validator = SilentPersistorNoBrainer.create(name: 'name')
        expect(validator).to be_valid
        expect(validator).to be_sleeping

        validator.name = nil
        expect(validator).not_to be_valid
        expect(validator.run!).to be_falsey
        expect(validator).to be_sleeping

        validator.reload
        expect(validator).not_to be_running
        expect(validator).to be_sleeping

        validator.name = 'another name'
        expect(validator).to be_valid
        expect(validator.run!).to be_truthy
        expect(validator).to be_running

        validator.reload
        expect(validator).to be_running
        expect(validator).not_to be_sleeping
      end

      it 'should store states for invalid models if configured' do
        persistor = InvalidPersistorNoBrainer.create(name: 'name')
        expect(persistor).to be_valid
        expect(persistor).to be_sleeping

        persistor.name = nil

        expect(persistor).not_to be_valid
        expect(persistor.run!).to be_truthy
        expect(persistor).to be_running

        persistor = InvalidPersistorNoBrainer.find(persistor.id)

        persistor.valid?
        expect(persistor).to be_valid
        expect(persistor).to be_running
        expect(persistor).not_to be_sleeping

        persistor.reload
        expect(persistor).to be_running
        expect(persistor).not_to be_sleeping
      end
    end
  end
end
