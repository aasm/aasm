# AASM - Ruby state machines

<a href="http://badge.fury.io/rb/aasm"><img src="https://badge.fury.io/rb/aasm@2x.png" alt="Gem Version" height="18"></a>
[![Build Status](https://travis-ci.org/aasm/aasm.svg?branch=master)](https://travis-ci.org/aasm/aasm)
[![Code Climate](https://codeclimate.com/github/aasm/aasm.png)](https://codeclimate.com/github/aasm/aasm)
[![Coverage Status](https://coveralls.io/repos/aasm/aasm/badge.png?branch=master)](https://coveralls.io/r/aasm/aasm)

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

When firing an event, you can pass a block to the method, it will be called only if
the transition succeeds :

```ruby
  job.run do
    job.user.notify_job_ran # Will be called if job.may_run? is true
  end
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

    event :run, :after => Proc.new { do_afterwards } do
      transitions :from => :sleeping, :to => :running, :on_transition => Proc.new {|obj, *args| obj.set_process(*args) }
    end

    event :sleep do
      after do
        ...
      end
      error do |e|
        ...
      end
      transitions :from => :running, :to => :sleeping
    end
  end

  def set_process(name)
    ...
  end

  def do_something
    ...
  end

  def do_afterwards
    ...
  end

end
```

In this case `do_something` is called before actually entering the state `sleeping`,
while `do_afterwards` is called after the transition `run` (from `sleeping` to `running`)
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

Also, you can pass parameters to events:

```ruby
  job = Job.new
  job.run(:running, :defragmentation)
```

In this case the `set_process` would be called with `:defragmentation` argument.

Note that when passing arguments to a state transition, the first argument must be the desired end state. In the above example, we wish to transition to `:running` state and run the callback with `:defragmentation` argument. You can also pass in `nil` as the desired end state, and AASM will try to transition to the first end state defined for that event.

In case of an error during the event processing the error is rescued and passed to `:error`
callback, which can handle it or re-raise it for further propagation.

During the `:on_transition` callback (and reliably only then) you can access the
originating state (the from-state) and the target state (the to state), like this:

```ruby
  def set_process(name)
    logger.info "from #{aasm.from_state} to #{aasm.to_state}"
  end
```

#### The current event triggered

While running the callbacks you can easily retrieve the name of the event triggered
by using `aasm.current_event`:

```ruby
  # taken the example callback from above
  def do_something
    puts "triggered #{aasm.current_event}"
  end
```

and then

```ruby
  job = Job.new

  # without bang
  job.sleep # => triggered :sleep

  # with bang
  job.sleep! # => triggered :sleep!
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

You can even provide a number of guards, which all have to succeed to proceed

```ruby
    def walked_the_dog?; ...; end

    event :sleep do
      transitions :from => :running, :to => :sleeping, :guards => [:cleaning_needed?, :walked_the_dog?]
    end
```

If you want to provide guards for all transitions within an event, you can use event guards

```ruby
    event :sleep, :guards => [:walked_the_dog?] do
      transitions :from => :running, :to => :sleeping, :guards => [:cleaning_needed?]
      transitions :from => :cleaning, :to => :sleeping
    end
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

#### ActiveRecord enums

You can use
[enumerations](http://edgeapi.rubyonrails.org/classes/ActiveRecord/Enum.html)
in Rails 4.1+ for your state column:

```ruby
class Job < ActiveRecord::Base
  include AASM

  enum state: {
    sleeping: 5,
    running: 99
  }

  aasm :column => :state, :enum => true do
    state :sleeping, :initial => true
    state :running
  end
end
```

You can explicitly pass the name of the method which provides access
to the enumeration mapping as a value of ```enum```, or you can simply
set it to ```true```. In the latter case AASM will try to use
pluralized column name to access possible enum states.

Furthermore, if your column has integer type (which is normally the
case when you're working with Rails enums), you can omit ```:enum```
setting --- AASM auto-detects this situation and enabled enum
support. If anything goes wrong, you can disable enum functionality
and fall back to the default behavior by setting ```:enum```
to ```false```.

### Sequel

AASM also supports [Sequel](http://sequel.jeremyevans.net/) besides _ActiveRecord_ and _Mongoid_.

```ruby
class Job < Sequel::Model
  include AASM

  aasm do # default column: aasm_state
    ...
  end
end
```

However it's not yet as feature complete as _ActiveRecord_. For example, there are
scopes defined yet. See [Automatic Scopes](#automatic-scopes).

### Mongoid

AASM also supports persistence to Mongodb if you're using Mongoid. Make sure
to include Mongoid::Document before you include AASM.

```ruby
class Job
  include Mongoid::Document
  include AASM
  field :aasm_state
  aasm do
    ...
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

  def self.sleeping
    "This method name is in already use"
  end
end
```

```ruby
class JobsController < ApplicationController
  def index
    @running_jobs = Job.running
    @recent_cleaning_jobs = Job.cleaning.where('created_at >=  ?', 3.days.ago)

    # @sleeping_jobs = Job.sleeping   #=> "This method name is in already use"
  end
end
```

If you don't need scopes (or simply don't want them), disable their creation when
defining the `AASM` states, like this:

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm :create_scopes => false do
    state :sleeping, :initial => true
    state :running
    state :cleaning
  end
end
```


### Transaction support

Since version *3.0.13* AASM supports ActiveRecord transactions. So whenever a transition
callback or the state update fails, all changes to any database record are rolled back.
Mongodb does not support transactions.

If you want to make sure a depending action happens only after the transaction is committed,
use the `after_commit` callback, like this:

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

If you want to encapsulate state changes within an own transaction, the behavior
of this nested transaction might be confusing. Take a look at
[ActiveRecord Nested Transactions](http://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html)
if you want to know more about this. Nevertheless, AASM by default requires a new transaction
`transaction(:requires_new => true)`. You can override this behavior by changing
the configuration

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm :requires_new_transaction => false do
    ...
  end

  ...
end
```

which then leads to `transaction(:requires_new => false)`, the Rails default.


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
    remove_column :jobs, :aasm_state
  end
end
```

### Inspection

AASM supports a couple of methods to find out which states or events are provided or permissible.

Given the `Job` class from above:

```ruby
job = Job.new

job.aasm.states.map(&:name)
=> [:sleeping, :running, :cleaning]

job.aasm.states(:permissible => true).map(&:name)
=> [:running]
job.run
job.aasm.states(:permissible => true).map(&:name)
=> [:cleaning, :sleeping]

job.aasm.events
=> [:run, :clean, :sleep]
```



## <a id="installation">Installation ##

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

Take a look at the [CHANGELOG](https://github.com/aasm/aasm/blob/master/CHANGELOG.md) for details about recent changes to the current version.

## Questions? ##

Feel free to

* [create an issue on GitHub](https://github.com/aasm/aasm/issues)
* [ask a question on StackOverflow](http://stackoverflow.com) (tag with `aasm`)
* send us a tweet [@aasm](http://twitter.com/aasm)

## Maintainers ##

* [Scott Barron](https://github.com/rubyist) (2006–2009, original author)
* [Travis Tilley](https://github.com/ttilley) (2009–2011)
* [Thorsten Böttger](http://github.com/alto) (since 2011)


## Warranty ##

This software is provided "as is" and without any express or
implied warranties, including, without limitation, the implied
warranties of merchantibility and fitness for a particular
purpose.

## License ##

Copyright (c) 2006-2014 Scott Barron

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
