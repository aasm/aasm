# Migrating from _AASM_ version 3 to 4

## Must

### `after_commit` hooks are now event-based

The `after_commit` hooks have been move from the state level to the event level.
So, if you want some code block to be executed after the _AASM_ state has been
saved **AND** committed, change this code

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm do
    state :sleeping, :initial => true
    state :running, :after_commit => :notify_about_running_job

    event :run do
      transitions :from => :sleeping, :to => :running
    end
  end

  def notify_about_running_job
    ...
  end
end
```

to

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm do
    state :sleeping, :initial => true
    state :running

    event :run, :after_commit => :notify_about_running_job do
      transitions :from => :sleeping, :to => :running
    end
  end

  def notify_about_running_job
    ...
  end
end
```

## Could

### Triggering an event without _to_state_

When providing parameters to callbacks it is not required to provide the `to_state`
anymore. So, assuming you have the following class:

```ruby
class Job
  include AASM

  aasm do
    state :sleeping, :initial => true
    state :running

    event :run do
      transitions :from => :sleeping, :to => :running, :after => :log
    end
  end

  def log(message)
    logger.info message
  end
end
```

then you could change from

```ruby
job = Job.new
job.run(:running, "we want to run")
```

to this:

```ruby
job = Job.new
job.run("we want to run")

job.run(:running, "we want to run") # still supported to select the target state (the _to_state_)
```

### New configuration option: `no_direct_assignment`

If you want to make sure that the _AASM_ column for storing the state is not directly assigned,
configure _AASM_ to not allow direct assignment, like this:

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm :no_direct_assignment => true do
    state :sleeping, :initial => true
    state :running

    event :run do
      transitions :from => :sleeping, :to => :running
    end
  end

end
```

resulting in this:

```ruby
job = Job.create
job.aasm_state # => 'sleeping'
job.aasm_state = :running # => raises AASM::NoDirectAssignmentError
job.aasm_state # => 'sleeping'
```
