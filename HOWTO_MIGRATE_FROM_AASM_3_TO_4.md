# How to migrate from AASM version 3 to 4?

## callback arguments

On one hand, when using callbacks like this

```ruby
class MyClass
  aasm do
    ...
    event :close, :before => :before do
      transitions :to => :closed, :from => :open, :on_transition => :transition_proc
    end
  end
  def transition_proc(arg1, arg2); end
  def before(arg1, arg2); end
  ...
end
```

you don't have to provide the target state as first argument anymore. So, instead of

```ruby
my_class = MyClass.new
my_class.close(:closed, arg1, arg2)
```

you can leave that away now

```ruby
my_class.close(arg1, args)
```

On the other hand, you have to accept the arguments for **all** callback methods (and procs)
you provide and use. If you don't want to provide these, you can splat them

```ruby
def before(*args); end
# or
def before(*_); end # to indicate that you don't want to use the arguments
```
