# Reproduces aasm/aasm#793 and aasm/aasm#535.
#
# The AASM state column (:aasm_state, the default) is backed by a Mongoid
# aliased field: the database/storage name is :as and the Ruby accessor alias
# is :aasm_state.
#
# In this configuration Mongoid keys `attribute_names` and `attributes` by the
# storage name (:as), while AASM's `attribute_name` resolves to the alias
# (:aasm_state). Therefore `attribute_names.include?("aasm_state")` is false
# and `attributes["aasm_state"]` is nil, which used to make
# `aasm_ensure_initial_state` evaluate `nil.empty?` and raise NoMethodError on
# instantiation (see lib/aasm/persistence/mongoid_persistence.rb).
class AliasedFieldMongoid
  include Mongoid::Document
  include AASM

  field :as, as: :aasm_state, type: String

  aasm do
    state :new, initial: true
    state :accepted
    state :rejected

    event :accept do
      transitions from: :new, to: :accepted
    end

    event :reject do
      transitions from: :new, to: :rejected
    end
  end
end
