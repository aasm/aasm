# AASM - Ruby state machines [![Build Status](https://secure.travis-ci.org/aasm/aasm.png)](http://travis-ci.org/aasm/aasm) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/aasm/aasm)

This package contains AASM, a library for adding finite state machines to Ruby classes.

AASM started as the *acts_as_state_machine* plugin but has evolved into a more generic library
that no longer targets only ActiveRecord models. It currently provides adapters for
[ActiveRecord](http://api.rubyonrails.org/classes/ActiveRecord/Base.html) and
[Mongoid](http://mongoid.org/), but it can be used for any Ruby class, no matter what
parent class it has (if any).

## Usage

Adding a state machine is as simple as including the AASM module and start defining
**states** and **events** together with their **transitions**:

```ruby
class Job
  include AASM

  aasm do
    state :sleeping, :initial => true
    state :running
    state :cleaning

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
```

This provides you with a couple of public methods for instances of the class `Job`:

```ruby
job = Job.new
job.sleeping? # => true
job.may_run?  # => true
job.run
job.running?  # => true
job.sleeping? # => false
job.may_run?  # => false
job.run       # => raises AASM::InvalidTransition
```

If you don't like exceptions and prefer a simple `true` or `false` as response, tell
AASM not to be *whiny*:

```ruby
class Job
  ...
  aasm :whiny_transitions => false do
    ...
  end
end

job.running?  # => true
job.may_run?  # => false
job.run       # => false
```

### Callbacks

You can define a number of callbacks for your transitions. These methods will be
called, when certain criteria are met, like entering a particular state:

```ruby
class Job
  include AASM

  aasm do
    state :sleeping, :initial => true, :before_enter => :do_something
    state :running

    event :run, :after => :notify_somebody do
      transitions :from => :sleeping, :to => :running
    end

    event :sleep do
      transitions :from => :running, :to => :sleeping
    end
  end

  def do_something
    ...
  end

  def notify_somebody
    ...
  end

end
```

In this case `do_something` is called before actually entering the state `sleeping`,
while `notify_somebody` is called after the transition `run` (from `sleeping` to `running`)
is finished.

Here you can see a list of all possible callbacks, together with their order of calling:

```ruby
  event:before
    previous_state:before_exit
      new_state:before_enter
        ...update state...
      previous_state:after_exit
    new_state:after_enter
  event:after
```

### Guards

Let's assume you want to allow particular transitions only if a defined condition is
given. For this you can set up a guard per transition, which will run before actually
running the transition. If the guard returns `false` the transition will be
denied (raising `AASM::InvalidTransition` or returning `false` itself):

```ruby
class Job
  include AASM

  aasm do
    state :sleeping, :initial => true
    state :running
    state :cleaning

    event :run do
      transitions :from => :sleeping, :to => :running
    end

    event :clean do
      transitions :from => :running, :to => :cleaning
    end

    event :sleep do
      transitions :from => :running, :to => :sleeping, :guard => :cleaning_needed?
    end
  end

  def cleaning_needed?
    false
  end

end

job = Job.new
job.run
job.may_sleep?  # => false
job.sleep       # => raises AASM::InvalidTransition
```


### ActiveRecord

AASM comes with support for ActiveRecord and allows automatical persisting of the object's
state in the database.

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm do # default column: aasm_state
    state :sleeping, :initial => true
    state :running

    event :run do
      transitions :from => :sleeping, :to => :running
    end

    event :sleep do
      transitions :from => :running, :to => :sleeping
    end
  end

end
```

You can tell AASM to auto-save the object or leave it unsaved

```ruby
job = Job.new
job.run   # not saved
job.run!  # saved
```

Saving includes running all validations on the `Job` class. If you want make sure
the state gets saved without running validations (and thereby maybe persisting an
invalid object state), simply tell AASM to skip the validations:

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm :skip_validation_on_save => true do
    state :sleeping, :initial => true
    state :running

    event :run do
      transitions :from => :sleeping, :to => :running
    end

    event :sleep do
      transitions :from => :running, :to => :sleeping
    end
  end

end
```

### Automatic Scopes

AASM will automatically create scope methods for each state in the model.

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm do
    state :sleeping, :initial => true
    state :running
    state :cleaning
  end

  def sleeping
    "This method name is in already use"
  end
end
```

```ruby
class JobsController < ApplicationController
  def index
    @running_jobs = jobs.running
    @recent_cleaning_jobs = jobs.cleaning.where('created_at >=  ?', 3.days.ago)

    # @sleeping_jobs = jobs.sleeping   #=> "This method name is in already use"
  end
end
```

### Transaction support

Since version *3.0.13* AASM supports ActiveRecord transactions. So whenever a transition
callback or the state update fails, all changes to any database record are rolled back.

### Column name & migration

As a default AASM uses the column `aasm_state` to store the states. You can override
this by defining your favorite column name, using `:column` like this:

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm :column => 'my_state' do
    ...
  end

end
```

Whatever column name is used, make sure to add a migration to provide this column
(of type `string`):

```ruby
class AddJobState < ActiveRecord::Migration
  def self.up
    add_column :jobs, :aasm_state, :string
  end

  def self.down
    remove_column :job, :aasm_state
  end
end
```

## Installation ##

### Manually from RubyGems.org ###

```sh
% gem install aasm
```

### Or if you are using Bundler ###

```ruby
# Gemfile
gem 'aasm'
```

### Building your own gems ###

```sh
% rake build
% sudo gem install pkg/aasm-x.y.z.gem
```

## Latest changes ##

Look at the [CHANGELOG](https://github.com/aasm/aasm/blob/master/CHANGELOG.md) for details.


## Authors ##

* [Scott Barron](https://github.com/rubyist)
* [Travis Tilley](https://github.com/ttilley)
* [Thorsten Böttger](http://github.com/alto)


## Warranty ##

This software is provided "as is" and without any express or
implied warranties, including, without limitation, the implied
warranties of merchantibility and fitness for a particular
purpose.

## License ##

Copyright (c) 2006-2012 Scott Barron

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
