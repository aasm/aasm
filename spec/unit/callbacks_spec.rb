require 'spec_helper'

describe 'callbacks for the new DSL' do
  let(:callback) {CallbackNewDsl.new}

  it "be called in order" do
    expect(callback).to receive(:exit_open).once.ordered
    expect(callback).to receive(:before).once.ordered
    expect(callback).to receive(:before_exit_open).once.ordered                   # these should be before the state changes
    expect(callback).to receive(:before_enter_closed).once.ordered
    expect(callback).to receive(:enter_closed).once.ordered
    expect(callback).to receive(:aasm_write_state).once.ordered.and_return(true)  # this is when the state changes
    expect(callback).to receive(:after_exit_open).once.ordered                    # these should be after the state changes
    expect(callback).to receive(:after_enter_closed).once.ordered
    expect(callback).to receive(:after).once.ordered

    callback.close!
  end
end

describe 'event callbacks' do
  describe "with an error callback defined" do
    before do
      class Foo
        aasm do
          event :safe_close, :success => :success_callback, :error => :error_callback do
            transitions :to => :closed, :from => [:open]
          end
        end
      end

      @foo = Foo.new
    end

    it "should run error_callback if an exception is raised and error_callback defined" do
      def @foo.error_callback(e); end

      allow(@foo).to receive(:enter).and_raise(e=StandardError.new)
      expect(@foo).to receive(:error_callback).with(e)

      @foo.safe_close!
    end

    it "should raise NoMethodError if exceptionis raised and error_callback is declared but not defined" do
      allow(@foo).to receive(:enter).and_raise(StandardError)
      expect{@foo.safe_close!}.to raise_error(NoMethodError)
    end

    it "should propagate an error if no error callback is declared" do
        allow(@foo).to receive(:enter).and_raise("Cannot enter safe")
        expect{@foo.close!}.to raise_error(StandardError, "Cannot enter safe")
    end
  end

  describe "with aasm_event_fired defined" do
    before do
      @foo = Foo.new
      def @foo.aasm_event_fired(event, from, to); end
    end

    it 'should call it for successful bang fire' do
      expect(@foo).to receive(:aasm_event_fired).with(:close, :open, :closed)
      @foo.close!
    end

    it 'should call it for successful non-bang fire' do
      expect(@foo).to receive(:aasm_event_fired)
      @foo.close
    end

    it 'should not call it for failing bang fire' do
      allow(@foo.aasm).to receive(:set_current_state_with_persistence).and_return(false)
      expect(@foo).not_to receive(:aasm_event_fired)
      @foo.close!
    end
  end

  describe "with aasm_event_failed defined" do
    before do
      @foo = Foo.new
      def @foo.aasm_event_failed(event, from); end
    end

    it 'should call it when transition failed for bang fire' do
      expect(@foo).to receive(:aasm_event_failed).with(:null, :open)
      expect {@foo.null!}.to raise_error(AASM::InvalidTransition)
    end

    it 'should call it when transition failed for non-bang fire' do
      expect(@foo).to receive(:aasm_event_failed).with(:null, :open)
      expect {@foo.null}.to raise_error(AASM::InvalidTransition)
    end

    it 'should not call it if persist fails for bang fire' do
      allow(@foo.aasm).to receive(:set_current_state_with_persistence).and_return(false)
      expect(@foo).to receive(:aasm_event_failed)
      @foo.close!
    end
  end
end
