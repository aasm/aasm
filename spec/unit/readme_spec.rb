require 'spec_helper'

describe 'testing the README examples' do

  it 'Usage' do
    class Job
      include AASM

      aasm do
        state :sleeping, :initial => true
        state :running, :cleaning

        event :run do
          transitions :from => :sleeping, :to => :running
        end

        event :clean do
          transitions :from => :running, :to => :cleaning
        end

        event :sleep do
          transitions :from => [:running, :cleaning], :to => :sleeping
        end
      end
    end

    job = Job.new

    expect(job.sleeping?).to eql true
    expect(job.may_run?).to eql true

    job.run

    expect(job.running?).to eql true
    expect(job.sleeping?).to eql false
    expect(job.may_run?).to eql false

    expect { job.run }.to raise_error(AASM::InvalidTransition)
  end

end
