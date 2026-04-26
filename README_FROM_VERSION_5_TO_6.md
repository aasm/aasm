README_FROM_VERSION_5_TO_6.md

# Migrating from _AASM_ version 5 to 6

## Must

### Ruby 2 is no longer supported

_AASM_ 6 requires Ruby 3.0+. Ruby 2.x reached end-of-life in March 2024.

### Rails 6 is no longer supported

_AASM_ 6 requires Rails 7.0+ for ActiveRecord integration. Rails 6 reached end-of-life in June 2024.

### `whiny_persistence` is now enabled by default

In AASM v5, `whiny_persistence` defaults to `false`. This means bang event methods (e.g., `save!`, `create!`) silently return `false` when an ActiveRecord model fails validation during a state transition.

In AASM v6, the default has changed to `true`. Bang event methods will now **raise an error** if the model is invalid when persisting a state change.

To restore the old behavior, explicitly set `whiny_persistence` to `false`:

```ruby
aasm do
  aasm :whiny_persistence => false
end
```
