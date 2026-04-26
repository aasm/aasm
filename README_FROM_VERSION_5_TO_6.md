# Migrating from _AASM_ version 5 to 6

## Must

### Namespaced event methods no longer define plain-named methods

When using `namespace:`, event methods are now defined directly with the namespace
suffix. The plain-named methods are no longer created. This fixes a long-standing
issue where two namespaced state machines with the same event name would collide,
with the second definition silently overwriting the first.

Before (v5):

```ruby
class Vehicle
  include AASM

  aasm(:car, namespace: :car) do
    state :unsold, initial: true
    state :sold

    event :sell do
      transitions from: :unsold, to: :sold
    end
  end
end

vehicle = Vehicle.new
vehicle.sell!       # worked (plain method, defined first)
vehicle.sell_car!   # worked (alias pointing to plain method)
vehicle.may_sell?   # worked
```

After (v6):

```ruby
vehicle = Vehicle.new
vehicle.sell!       # => NoMethodError — no longer defined
vehicle.sell_car!   # works (directly defined)
vehicle.may_sell?   # => NoMethodError — no longer defined
vehicle.may_sell_car? # works
```

**Migration:** Replace all calls to plain event methods with their namespaced
equivalents:

- `sell!` → `sell_car!`
- `sell` → `sell_car`
- `may_sell?` → `may_sell_car?`
- `sell_without_validation!` → `sell_car_without_validation!`

The `aasm.fire(:event)` and `aasm.fire!(:event)` APIs continue to accept the
plain event name and resolve to the correct namespaced method internally. No
changes needed for code using this API:

```ruby
vehicle.aasm(:car).fire!(:sell)  # still works, resolves to sell_car! internally
```

### If you manually prefixed event names to work around collisions

In v5, a common workaround for the collision problem was to manually include the
namespace in the event name. In v6, this is no longer needed because the namespace
is applied automatically. If you don't update your DSL, you'll end up with a
double suffix:

Before (v5 workaround):

```ruby
aasm(:review_status, namespace: :review) do
  event :approve_review do  # manual prefix to avoid collision with another :approve
    transitions from: :unapproved, to: :approved
  end
end

obj.approve_review   # worked in v5
obj.approve_review!  # worked in v5
```

After (v6, if you don't update):

```ruby
# The namespace "review" is now appended automatically, resulting in:
obj.approve_review_review   # double suffix!
obj.approve_review_review!  # double suffix!
```

**Migration:** Remove the manual namespace prefix from event names in the DSL:

```ruby
aasm(:review_status, namespace: :review) do
  event :approve do  # just use the plain name
    transitions from: :unapproved, to: :approved
  end
end

obj.approve_review   # correct — namespace applied automatically
obj.approve_review!  # correct
```

### `whiny_persistence` is now `true` by default

Previously, `whiny_persistence` defaulted to `false`, meaning bang events (`run!`)
would silently return `false` when the object failed persistence (e.g. ActiveRecord
validation errors). Now it defaults to `true`, raising an exception instead.

Before (v5):

```ruby
job.run!  # => false (if validation fails, no exception raised)
```

After (v6):

```ruby
job.run!  # => raises AASM::InvalidTransition (if validation fails)
```

**Migration:** If you relied on the silent `false` behavior, explicitly set
`whiny_persistence: false`:

```ruby
class Job < ActiveRecord::Base
  include AASM

  aasm whiny_persistence: false do
    ...
  end
end
```
